
$CONFIG_FILE_SEARCH_PATH = './ConEmu.xml'
$CONFIG_FILE_BACKUP_PATH = './ConEmu.bak.xml'
$COLORSCHEME_DIR_SEARCH_PATH = './ConEmu_Colorschemes'

Function ParseColorschemeFile ($FileName, $FileContent) {
  $ColorschemeObject = @{ Name = $FileName }

  if ($FileName -match '(.+?)\.Xresources') {
    $acceptable_keys = @(
      'color0' , 'color1' , 'color2' , 'color3' , 'color4', 'color5' , 'color6' , 'color7',
      'color8' , 'color9' , 'color10' , 'color11' , 'color12' , 'color13' , 'color14' , 'color15'
    )

    $abc = $acceptable_keys | ForEach-Object {
      # TODO
      if ([string]$FileContent -match "${_}:\s*#([a-z0-9A-Z]+?)\b") {
        $ColorschemeObject[$_] = $matches[1]
      }
      else {
        $null
      }
    }
  }

  if ($ColorschemeObject.Name) {
    return $ColorschemeObject
  }
  else {
    return $null
  }
}

Function ConstructMarkupFragment ($DocRoot, $Colorscheme) {
  Function _CC ($c) {
    $c.SubString(4, 2) + $c.SubString(2, 2) + $c.SubString(0, 2)
  }

  $refDoc = [xml]@"
    <key name="Palette?">
      <value name="Name" type="string" data="CCSG__$($Colorscheme.Name)"/>
      <value name="TextColorIdx" type="hex" data="10"/>
      <value name="BackColorIdx" type="hex" data="10"/>
      <value name="PopTextColorIdx" type="hex" data="10"/>
      <value name="PopBackColorIdx" type="hex" data="10"/>
      <value name="ColorTable00" type="dword" data="00$(_CC($Colorscheme.color0 ))"/>
      <value name="ColorTable01" type="dword" data="00$(_CC($Colorscheme.color4 ))"/>
      <value name="ColorTable02" type="dword" data="00$(_CC($Colorscheme.color2 ))"/>
      <value name="ColorTable03" type="dword" data="00$(_CC($Colorscheme.color6 ))"/>
      <value name="ColorTable04" type="dword" data="00$(_CC($Colorscheme.color1 ))"/>
      <value name="ColorTable05" type="dword" data="00$(_CC($Colorscheme.color5 ))"/>
      <value name="ColorTable06" type="dword" data="00$(_CC($Colorscheme.color3 ))"/>
      <value name="ColorTable07" type="dword" data="00$(_CC($Colorscheme.color7 ))"/>
      <value name="ColorTable08" type="dword" data="00$(_CC($Colorscheme.color8 ))"/>
      <value name="ColorTable09" type="dword" data="00$(_CC($Colorscheme.color12))"/>
      <value name="ColorTable10" type="dword" data="00$(_CC($Colorscheme.color10))"/>
      <value name="ColorTable11" type="dword" data="00$(_CC($Colorscheme.color14))"/>
      <value name="ColorTable12" type="dword" data="00$(_CC($Colorscheme.color9 ))"/>
      <value name="ColorTable13" type="dword" data="00$(_CC($Colorscheme.color13))"/>
      <value name="ColorTable14" type="dword" data="00$(_CC($Colorscheme.color11))"/>
      <value name="ColorTable15" type="dword" data="00$(_CC($Colorscheme.color15))"/>
    </key>
"@

  return ($DocRoot.ImportNode($refDoc.DocumentElement, $true))
}

Function MainEntry () {
  # load config file
  $ConfigDocumentRoot = [xml](Get-Content -Encoding utf8 -Path $CONFIG_FILE_SEARCH_PATH)
  $ConfigColorCountNode = $ConfigDocumentRoot.SelectNodes("//key[@name='Colors']/value[@name='Count']")[0]
  $ConfigColorRoot = $ConfigColorCountNode.ParentNode

  # remove stale nodes
  $stale_nodes = $ConfigColorRoot.key |
  Where-Object { $_.value | Where-Object { $_.name -eq 'Name' -and $_.data -like 'CCSG__*' } }
  $stale_nodes | ForEach-Object { $ConfigColorRoot.RemoveChild($_) }

  # read and parse colorschemes
  $AttachedColorschemes = Get-ChildItem $COLORSCHEME_DIR_SEARCH_PATH |
  ForEach-Object { ParseColorschemeFile $_.Name (Get-Content $_.FullName) }
  Write-Output $AttachedColorschemes.Count

  # append updated nodes
  $AttachedColorschemes | ForEach-Object {
    $node = ConstructMarkupFragment $ConfigDocumentRoot $_
    $ConfigColorRoot.AppendChild($node)
  }

  # rewrite counts
  $ColorschemeCount = $ConfigColorRoot.ChildNodes.Count - 1
  $ConfigColorCountNode.data = [string]$ColorschemeCount
  For ($i = 0; $i -lt $ColorschemeCount; $i++) {
    $ConfigColorRoot.key[$i].name = "Palette$($i + 1)"
  }

  # write to file
  If (Get-Item $CONFIG_FILE_SEARCH_PATH) {
    Move-Item $CONFIG_FILE_SEARCH_PATH $CONFIG_FILE_BACKUP_PATH -Force
  }
  $ConfigDocumentRoot.Save($CONFIG_FILE_SEARCH_PATH)
  # $ConfigDocumentRoot.Save('New_Conf.xml')
}


# $AttachedColorschemes = Get-ChildItem './colorschemes' | ForEach-Object { ParseColorschemeFile $_.Name (Get-Content $_.FullName) }
# Write-Output $AttachedColorschemes
MainEntry
