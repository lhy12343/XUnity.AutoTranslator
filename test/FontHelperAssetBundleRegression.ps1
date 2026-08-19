$ErrorActionPreference = 'Stop'

$sourcePath = Join-Path $PSScriptRoot '..\src\XUnity.AutoTranslator.Plugin.Core\Fonts\FontHelper.cs'
$source = Get-Content -Raw -LiteralPath $sourcePath

$managedBlock = [regex]::Match(
    $source,
    '(?s)#if MANAGED(?<body>.*?)#else'
)

if (-not $managedBlock.Success) {
    throw 'Could not find the managed AssetBundle loading branch.'
}

$body = $managedBlock.Groups['body'].Value
if ($body -match 'TMP_FontAsset\.UnityType') {
    throw 'Regression: the managed branch still filters AssetBundle loading to TMP_FontAsset and can omit its atlas/material.'
}
if ($body -notmatch 'bundle\.LoadAllAssets\(\)') {
    throw 'Regression: the managed branch must load all AssetBundle root objects.'
}
if ($body -notmatch 'TMP_FontAsset\.ClrType\.IsInstanceOfType') {
    throw 'Regression: the managed branch must select the TMP_FontAsset after loading all root objects.'
}
if ($body -notmatch 'atlasTextures' -or $body -notmatch '"material"') {
    throw 'Regression: the managed branch must repair the TMP atlas and material references.'
}

Write-Output 'PASS: managed TMP font loading retains and repairs all AssetBundle root objects.'
