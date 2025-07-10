return {
  ["napalmgoo"] = {
    dirtg = {
      air                = true,
      class              = "CSimpleParticleSystem",
      count              = 10, -- how much goo?
      ground             = true,
	  water				 = true,
      properties = {
        airdrag            = 0.7,
        colormap           = [[1 1 1 0.25  0.025 0.025 0.025 0.25  0 0 0 0]],
        directional        = true,
        emitrot            = 0,
        emitrotspread      = 32,
        --emitvector         = [[0, 1, 0]],
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
        texture            = "flameball", --"new_dirta",
        useairlos          = false,
      },
    },
  },
}