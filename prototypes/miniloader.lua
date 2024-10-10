local flib = require("__flib__/data-util")

local ml_entity = flib.copy_prototype(data.raw["loader-1x1"]["loader-1x1"], "miniloader")

ml_entity.structure = {
  direction_in = {
    sheets = {
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-base.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 0
      },
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-mask.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 0,
        -- tint = tint
      },
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-shadow.png",
        draw_as_shadow = true,
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 0
      }
    }
  },
  direction_out = {
    sheets = {
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-base.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 192
      },
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-mask.png",
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 192,
        -- tint = tint
      },
      {
        filename = "__miniloader_modernized__/graphics/entity/hr-miniloader-structure-shadow.png",
        draw_as_shadow = true,
        priority = "extra-high",
        width = 192,
        height = 192,
        scale = 0.5,
        y = 192
      },
    }
  }
}

ml_entity.circuit_connector = circuit_connector_definitions.create_vector
(
  universal_connector_template,
  {
    -- Variations when loader is an output
    { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = util.by_pixel(10, -0.5), show_shadow = false }, -- N
    { variation = 2, main_offset = util.by_pixel(0, -3), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- E
    { variation = 0, main_offset = util.by_pixel(3, 0), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- S
    { variation = 6, main_offset = util.by_pixel(0, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- W

    -- Variations when loader is an input
    { variation = 0, main_offset = util.by_pixel(3, 0), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- N
    { variation = 6, main_offset = util.by_pixel(0, 2), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- E
    { variation = 24, main_offset = util.by_pixel(-17, 0), shadow_offset = util.by_pixel(10, -0.5), show_shadow = false }, -- S
    { variation = 2, main_offset = util.by_pixel(0, -3), shadow_offset = util.by_pixel(7.5, 7.5), show_shadow = false }, -- W
  }
)

ml_entity.circuit_wire_max_distance = transport_belt_circuit_wire_max_distance

data:extend{
  ml_entity
}