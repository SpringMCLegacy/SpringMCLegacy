local featureDefs = {
  Wall_X = {
    blocking           = false,
    category           = "corpses",
    damage             = 5400,
    description        = "Wrecked Wall",
    featureDead        = "Wreck_X",
    collisionVolumeType = "box",
	collisionVolumeScales = "70 70 25",
	collisionVolumeOffsets = "0 10 0",
	collisionVolumeTest = 1,
    height             = "50",
    hitdensity         = "10",
    metal              = 0,
    object             = "Wall_X.s3o",
    reclaimable        = false,
    world              = "All Worlds",
  },
}
return featureDefs