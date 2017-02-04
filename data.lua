data:extend({
{
	type = "custom-input",
	name = "item_collect",
	key_sequence = "SHIFT + Z",
	consuming = "script-only"
}
})

function color_gen(input)
return
{
	type = "sprite",
	name = input.name,
	filename = "__core__/graphics/gui.png",
	priority = "extra-high-no-scale",
	width = 5,
	height = 5,
	x = input.x,
	y = input.y,
	scale = 1.5
}
end

data:extend({ color_gen{name = "color_G", x = 250, y = 0} })
data:extend({ color_gen{name = "color_Y", x = 278, y = 0} })
data:extend({ color_gen{name = "color_R", x = 306, y = 0} })
data:extend({ color_gen{name = "color_N", x = 310, y = 0} })

data.raw["gui-style"].default["LD_gauge"] =
{
	type = "button_style",
	-- parent = "button_style",
	width = 5,
	height = 5,
	default_graphical_set =
	{
		type = "monolith",
		monolith_image =
		{
			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			width = 5,
			height = 5,
			x = 221,
			y = 13,
			scale = 1.5
		}
	}
}