-- this is the first effect responsible for the unfolding of the sfx
return {
  ["ccssfxexpand"] = {
       alwaysvisible      = true,
     usedefaultexplosions = false,

    lensflare = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01          0 0 0 0.0]],
        directional        = true,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 55,
        particlelifespread = 0,
        particlesize       = [[1 ]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 1.000000000000001,
        sizemod            =  0.91,
        texture            = [[lensflareCenter]],
        useairlos          = false,
      },
    },
   
       expandstrobe = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01          0 0 0 0.0]],
        directional        = false,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 90,
        particlelifespread = 0,
        particlesize       = [[12 ]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 1.000000000000001,
        sizemod            =  0.975,
        texture            = [[expandingstrobe]],
        useairlos          = false,
      },
    },    
   
   innerspiral = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01          0 0 0 0.0]],
        directional        = false,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 90,
        particlelifespread = 0,
        particlesize       = [[2 ]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 1.000000000000001,
        sizemod            =  0.975,
        texture            = [[innerswirl]],
        useairlos          = false,
      },
    },
   
   outerspiral = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01          0 0 0 0.0]],
        directional        = false,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 90,
        particlelifespread = 0,
        particlesize       = [[8 ]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 1.000000000000001,
        sizemod            =  0.975,
        texture            = [[outerspira]],
        useairlos          = false,
      },
    },
   
   
      spark = {
      air                = true,
      class              = [[CSimpleParticleSystem]],   
   
      count              = 15,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[0.2 0.8 1 0.01  0.2 0.8 1 0.01     0 0 0 0.01]],   
   
        directional        = true,
        emitrot            = 5,
        emitrotspread      = 42,
        emitvector         = [[0 r-0.3 r0.3,-0.3, r-0.3 r0.3]],
      gravity            = [[0, 0.007, 0]], 
       numparticles       = 1,
        particlelife       = 35,
        particlelifespread = 20,
        particlesize       = 0.5,
        particlesizespread = 0,
        particlespeed      = 0.5,
        particlespeedspread = 1,
        pos                = [[0, 50, 0]],
   
        sizegrowth         = [[0.0 r.20]],
        sizemod            = 1.0,
        texture            = [[slicerspark1]],
      
        useairlos          = false,
      },
    },   

   spark2 = {
      air                = true,
      class              = [[CSimpleParticleSystem]],   
   
      count              = 15,
      ground             = true,
      water              = true,
      properties = {
        airdrag            = 1,
        colormap           = [[0.2 0.8 1 0.01  0.2 0.8 1 0.01     0 0 0 0.01]],   
   
        directional        = true,
        emitrot            = 5,
        emitrotspread      = 42,
        emitvector         = [[0 r-0.3 r0.3,0.3, r-0.3 r0.3]],
      gravity            = [[0, -0.007, 0]], 
       numparticles       = 1,
        particlelife       = 35,
        particlelifespread = 20,
        particlesize       = 0.5,
        particlesizespread = 0,
        particlespeed      = 0.5,
        particlespeedspread = 1,
        pos                = [[0, 50, 0]],
   
        sizegrowth         = [[0.0 r.20]],
        sizemod            = 1.0,
        texture            = [[slicerspark2]],
      
        useairlos          = false,
      },
    },  
     groundflash = {
      air                = false,
     
      alwaysvisible      = true,
      circlealpha        = 0.1,
      circlegrowth       = 3,
      flashalpha         = 0.9,
      flashsize          = 80,
      ground             = true,
      ttl                = 85,
      water              = false,
      color = {
        [1]  = 0,
        [2]  = 0.5,
        [3]  = 1,
      },
    },

  


   
   },


-- this is the second effect, responsible for the collaps back inward 


  ["ccssfxcontract"] = {
        alwaysvisible      = true,
     usedefaultexplosions = false,
   
   lensflare = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01         0 0 0 0.0]],
        directional        = true,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r-0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 55,
        particlelifespread = 0,
        particlesize       = [[15]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 0,
        sizemod            =  0.990,
        texture            = [[lensflareCenter]],
        useairlos          = false,
      },
    },
   contractstrobe = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.01   0.95 0.95 0.95  0.01    0.95 0.95 0.95  0.01         0 0 0 0.0]],
        directional        = true,
        emitrot            = 10,
        emitrotspread      = 10,
        emitvector         = [[0, 0 r-0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 65,
        particlelifespread = 0,
        particlesize       = [[45]],
        particlesizespread = 0,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 0,
        sizemod            =  0.989,
        texture            = [[expandingstrobe]],
        useairlos          = false,
      },
    },   
   collapsingspiral = {
      air                = true,
      class              = [[CSimpleParticleSystem]],
      count              = 1,
      ground             = true,
      properties = {
        airdrag            = 0.7,
        alwaysvisible      = true,
         colormap           = [[0.95 0.95 0.95  0.005   0.95 0.95 0.95  0.005    0.95 0.95 0.95  0.005         0 0 0 0.0]],
        directional        = false,
        emitrot            = 10,
        emitrotspread      = 43,
        emitvector         = [[0, 0 r-0.001 , 0]],
        gravity            = [[0, 0, 0]],
        numparticles       = 1,
        particlelife       = 45,
        particlelifespread = 30,
        particlesize       = [[25]],
        particlesizespread = 20,
        particlespeed      = 0,
        particlespeedspread = 0,
        pos                = [[0, 50, 0]],
        sizegrowth         = 0,
        sizemod            =  0.989,
        texture            = [[outerspira]],
        useairlos          = false,
      },
    },
      
      
   
   
   
   }
  }