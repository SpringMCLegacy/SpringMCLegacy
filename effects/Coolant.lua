return {
  ["greengoo"] = {
    dirtg = {
      air                = true,
      class              = "CSimpleParticleSystem",
      count              = 10, -- how much goo?
      ground             = true,
	  water				 = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
        colormap           = [[0.32 0.46 0.35 1  0.45 0.60 0.44 0.5]],
        directional        = true,
        emitrot            = 45,
        emitrotspread      = 32,
        emitvector         = [[0, -1, 0]],
        gravity            = [[0, -0.3, 0]], -- Adjust Y value to determine how fast the goo falls
        numparticles       = 4,
        particlelife       = 60, -- How long the goo falls
        particlelifespread = 20,
        particlesize       = 1,
        particlesizespread = 2,
        particlespeed      = 1,
        particlespeedspread = 4, -- How far out the goo will spread
        sizegrowth         = 1,
        sizemod            = 0.9,
        texture            = "new_dirta",
        useairlos          = false,
      },
    },
  },
}