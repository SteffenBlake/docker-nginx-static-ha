$REPO = "steffenblake/nginx-static-ha"
$VER = "1.0.0"

$ARCHLIST = @{
    arm = "arm/v7";
    arm64 = "arm64"; 
    amd64 = "amd64" 
}

$ManifestLatest = $Repo + ":latest"
$ManifestVer = $Repo + ":" + $VER

ForEach ($ARCH in $ARCHLIST.keys) {
  $ArchRepo = $Repo + ":linux-" + $ARCH
  $LatestRepo = $ArchRepo + "-latest"
  $VerRepo = $ArchRepo + "-" + $VER
  Write-Output "Pushing to $LatestRepo / $VerRepo"
  docker buildx build . --platform linux/$ARCH -t $LatestRepo -t $VerRepo --push
  Write-Output "Composing to Manifests $ManifestLatest / $ManifestVer"
  docker manifest create $ManifestLatest --amend $LatestRepo
  docker manifest create $ManifestVer --amend $VerRepo
}

Write-Output "Publishing to Manifests $ManifestLatest / $ManifestVer"

docker manifest push $ManifestLatest
docker manifest push $ManifestVer
