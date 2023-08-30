class Node : GraphVertex {

	[string] $file
	[int] $line

	[string] $content

	[int] $indent
	[string] $key
	
	$keyValue
	[object[]] $keyValueBlockLines = @()

	Node([string] $file, [int] $line)
		: base("$file@$line") {

		$this.file = $file
		$this.line = $line
	}

	[Node] FindNeighborByKey([string] $key) {
		return $this.getNeighbors() | Where-Object {
			$_.key -eq $key
		} | Select-Object -First 1
	}
}

class Yaml {

	[Graph] $nodeGraph
	[string] $rootNodeKey

	Yaml() {

		$this.nodeGraph = New-Object Graph($true)
		
		$rootNode = New-Object Node([Guid]::NewGuid(), 0)
		$rootNode.indent = -2
		$this.nodeGraph.addVertex($rootNode)
		$this.rootNodeKey = $rootNode.value
	}

	[Node] GetRootNode() {
		return $this.nodeGraph.getVertexByKey($this.rootNodeKey)
	}

	[string] ToYamlString() {
		return $this.ToYamlString($false)
	}

	[string] ToYamlString([bool] $debug) {
		return $this.ToYamlString($this.GetRootNode(), $debug)
	}

	[string] ToYamlString([Node] $node, [bool] $debug) {

		$nodeHeader = $debug ? '*' : ''
		$blockHeader = $debug ? '+' : ''

		$sb = New-Object Text.StringBuilder

		if ($node.indent -ge 0) {
			$data = "$nodeHeader$(New-Object String(' ', $node.indent))$($node.key): $($node.keyValue)"
			$sb.AppendFormat("{0}`n", $data)

			$node.keyValueBlockLines | ForEach-Object {
				$sb.AppendFormat("{0}{1}`n", $blockHeader, $_)
			}
		}
		$node.getNeighbors() | ForEach-Object {
			$sb.Append($this.ToYamlString($_, $debug))
		}
		return $sb.ToString()
	}
}

function Add-NodeEdge([Graph] $graph, [Node] $from, [Node] $to) {

	Write-Debug "Adding edge from $($from.value) ($($from.key)) to $($to.value) ($($to.key))..."
	foreach ($neighbor in $from.getNeighbors()) {
		if ($neighbor.value -eq $to.value) {
			return
		}
	}
	$graph.addEdge([GraphEdge]::new($from, $to)) | out-null
}

function Get-Yaml([string] $file) {

	# Note: Get-Yaml is a limited YAML parser meant to support specific use cases

	$yaml = New-Object Yaml
	
	$nodeStack = New-Object Collections.Stack
	$nodeStack.Push($yaml.GetRootNode())

	$line = 0

	$parsingCollection = $false
	$parsingCollectionIndent = 0
	$parsingBlockScaler = $false

	Get-Content $file | ForEach-Object {

		$line += 1

		$isComment = $_ -match '(?<indent>\s*)#'

		$_ -match '(?<indent>\s*)' | Out-Null
		$indent = $matches.indent.length

		if (-not $parsingCollection) {

			$parsingCollection = $_ -match '(?<indent>\s*)-'
			$parsingCollectionIndent = $indent
		}

		$isTag = $_ -match '(?<indent>\s*)(?<key>[^\s]+):\s*(?<keyValue>.+)?'
		$key = $matches.key
		$keyValue = $matches.keyValue

		if ($isTag -and (-not $parsingCollection -or ($parsingCollection -and $indent -le $parsingCollectionIndent))) {

			$parsingCollection = $false
			$parsingCollectionIndent = 0

			$node = New-Object Node($file, $line)
			$node.content = $_
			
			$node.indent = $indent
			$node.key = $key
			$node.keyValue = $keyValue

			# note: flow scalars are unsupported
			$parsingBlockScaler = $node.keyValue -match '(?:>|\|)(?:-|\+)?(?:[1-9])?'

			$yaml.nodeGraph.addVertex($node) | Out-Null

			$currentNode = $nodeStack.Pop()
			while ($currentNode.indent -gt $indent) {
				$currentNode = $nodeStack.Pop()
			}
			
			if ($node.indent -eq $currentNode.indent) { # sibling node

				$parentNode = $nodeStack.Pop()
				Add-NodeEdge $yaml.nodeGraph $parentNode $node

				$nodeStack.Push($parentNode)
				$nodeStack.Push($node)
			} elseif ($node.indent -gt $currentNode.indent) { # child node

				Add-NodeEdge $yaml.nodeGraph $currentNode $node

				$nodeStack.Push($currentNode)
				$nodeStack.Push($node)
			} else { # ancestor node

				$parentNode = $null
				$level = $currentNode.indent
				while ($level -gt $node.indent) {

					$parentNode = $nodeStack.Pop()
					$level = $parentNode.indent
				}

				Add-NodeEdge $yaml.nodeGraph $parentNode $node
				$nodeStack.Push($parentNode)
				$nodeStack.Push($node)
			}
		} elseif ($isComment -or $parsingBlockScaler -or $parsingCollection) {

			$currentNode = $nodeStack.Pop()
			$currentNode.keyValueBlockLines += $_
			$nodeStack.Push($currentNode)
		}
	}
	$yaml
}

function Merge-GraphNodeNeighbors([Graph] $graph, [Node] $parent, $neighbors) {

	$neighbors | ForEach-Object {

		# add neighbors
		$graph.addVertex($_) | Out-Null
		Add-NodeEdge $graph $parent $_

		# # add neighbor's neighbors
		Merge-GraphNodeNeighbors $graph $_ $_.getNeighbors()
	}
}

function Merge-YamlNodes([Graph] $graph, [Node] $leftNode, [Node] $rightNode) {

	# Note: Merge-YamlNodes is a limited YAML merger meant to support specific use cases

	$leftKeys = $leftNode.getNeighbors() | ForEach-Object { $_.key }

	if ($leftKeys.length -eq 0) {
		$leftNode.keyValue = $rightNode.keyValue
		$leftNode.keyValueBlockLines = $rightNode.keyValueBlockLines
		Merge-GraphNodeNeighbors $graph $leftNode $rightNode.getNeighbors()
		return
	}

	$neighborKeysToExplore = @()

	$rightNode.getNeighbors() | ForEach-Object {

		if ($leftKeys -notcontains $_.key) {

			# add right-only content
			$graph.addVertex($_) | Out-Null
			Add-NodeEdge $graph $leftNode $_
		} else {

			# traverse neighbors of the right node that match those of the left
			$neighborKeysToExplore += $_.key
		}
	}

	$neighborKeysToExplore | ForEach-Object {

		$leftNeighbor = $leftNode.FindNeighborByKey($_)
		$rightNeighbor = $rightNode.FindNeighborByKey($_)

		$leftNeighbor.keyValue = $rightNeighbor.keyValue
		$leftNeighbor.keyValueBlockLines = $rightNeighbor.keyValueBlockLines

		Merge-YamlNodes $graph $leftNeighbor $rightNeighbor
	}
}

function Merge-YamlFiles([string[]] $files) {

	# Note: Merge-YamlFiles is a limited YAML merger meant to support specific use cases

	if ($files.Length -le 0) {
		throw "Cannot merge $($files.Length) files!"
	}

	$leftYaml = Get-Yaml ($files | Select-Object -First 1)
	$files | Select-Object -Skip 1 | ForEach-Object {
		$rightYaml = Get-Yaml $_
		Merge-YamlNodes $leftYaml.nodeGraph $leftYaml.GetRootNode() $rightYaml.GetRootNode()
	}
	return $leftYaml
}