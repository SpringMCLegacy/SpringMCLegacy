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
        colormap           = [[0.32 0.46 0.35 1  0.45 0.60 0.44 0.5]],
        directional        = true,
        emitrot            = "ir45",
        emitrotspread      = 32,
        emitvector         = [[0, 1, 0]],
        gravity            = [[0, -0.7, 0]], -- Adjust Y value to determine how fast the goo falls 0.3
        numparticles       = 4,
        particlelife       = "ir60", -- How long the goo falls
        particlelifespread = "ir20",
        particlesize       = "ir1",
        particlesizespread = "ir3",--2,
        particlespeed      = 5,--1,
        particlespeedspread = "r6", -- How far out the goo will spread
        sizegrowth         = 1.1,--1,
        sizemod            = 0.9,
        texture            = "coolant", --"new_dirta",
        useairlos          = false,
      },
    },
  },
}