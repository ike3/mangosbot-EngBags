-- Constants
EngBags_DEBUGMESSAGES = 0;         -- 0 = off, 1 = on
EngBags_SHOWITEMDEBUGINFO = 0;
EngBot_WIPECONFIGONLOAD = 0;	-- for debugging, test it out on a new config every load
BINDING_HEADER_EngBot = "EngBot @ EngBags";
BINDING_NAME_EB_TOGGLE = "Toggle Bot Window";
EngBot_MAXBUTTONS = 144;
EngBot_TOP_PADWINDOW = 75;
EngBot_WINDOWBOTTOMPADDING_EDITMODE = 50;
EngBot_WINDOWBOTTOMPADDING_NORMALMODE = 25;
EngBot_WindowBottomPadding = EngBot_WINDOWBOTTOMPADDING_NORMALMODE;
EngBot_AtBot = 0;
EngReplaceBot          = 1;
local BotFrame_Saved = nil;

EngBot_item_cache = { {}, {}, {}, {}, {}, {}, {} };	-- cache of all the items as they appear in bags
EngBot_bar_positions = {};
EngBot_buttons = {};
EngBot_hilight_new = 0;
EngBot_edit_mode = 0;
EngBot_edit_hilight = "";         -- when editmode is 1, which items do you want to hilight
EngBot_edit_selected = "";        -- when editmode is 1, this is the class of item you clicked on
EngBot_RightClickMenu_mode = "";
EngBot_RightClickMenu_opts = {};
EngBot_Bags = { 1 }
EngBags_Bars = {"first", "second", "third"}
EngBot_NOTNEEDED = 0;	-- when items haven't changed, or only item counts
EngBot_REQUIRED = 1;	-- when items have changed location, but it's been sorted once and won't break if we don't sort again
EngBot_MANDATORY = 2;	-- it's never been sorted, the window is in an unstable state, you MUST sort.
EngBot_resort_required = EngBot_MANDATORY;
EngBot_window_update_required = EngBot_MANDATORY;
EngBot_lastItemNum = 1
EngBot_Mode = "bot_item"
EngBotConfig = {}

EngBot_BuildTradeList = {};	-- only build a full list of trade skill info once

EngBot_Catagories_Exclude_List = {};

EngBot_ConfigOptions_Default = {
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = { 1,0,0.25 }, ["align"] = "center",
		  ["text"] = "Window Options" },
	},
	{},	---------------------------------------------------------------------------------------

	{	-- Window Columns
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Columns:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = EngBags_MAXCOLUMNS_MIN },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = EngBags_MAXCOLUMNS_MIN, ["maxValue"] = EngBags_MAXCOLUMNS_MAX, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["maxColumns"];
			end,
		  ["func"] = function(v)
				EngBotConfig["maxColumns"] = tonumber(v);
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = EngBags_MAXCOLUMNS_MAX }
	},

	{	-- Button Size
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Button Size:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = EngBags_BUTTONSIZE_MIN },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = EngBags_BUTTONSIZE_MIN, ["maxValue"] = EngBags_BUTTONSIZE_MAX, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["frameButtonSize"];
			end,
		  ["func"] = function(v)
				EngBotConfig["frameButtonSize"] = tonumber(v);
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = EngBags_BUTTONSIZE_MAX }
	},

	{	-- Font Size / item count
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Item count font size:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = EngBags_FONTSIZE_MIN },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = EngBags_FONTSIZE_MIN, ["maxValue"] = EngBags_FONTSIZE_MAX, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["button_size_opts"]["EngBags_BUTTONFONTHEIGHT"];
			end,
		  ["func"] = function(v)
				EngBotConfig["button_size_opts"]["EngBags_BUTTONFONTHEIGHT"] = tonumber(v);
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = EngBags_FONTSIZE_MAX }
	},

	{	-- Font Size / New text
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "New tag font size:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = EngBags_FONTSIZE_MIN },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = EngBags_FONTSIZE_MIN, ["maxValue"] = EngBags_FONTSIZE_MAX, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["button_size_opts"]["EngBags_BUTTONFONTHEIGHT2"];
			end,
		  ["func"] = function(v)
				EngBotConfig["button_size_opts"]["EngBags_BUTTONFONTHEIGHT2"] = tonumber(v);
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = EngBags_FONTSIZE_MAX }
	},

	{},	---------------------------------------------------------------------------------------
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = { 1,0,0.25 }, ["align"] = "center",
		  ["text"] = "Display Strings & New Item Settings" },
	},
	{},	---------------------------------------------------------------------------------------
	{	-- "New" Text
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.5, ["color"] = { 1,1,0.25 },
		  ["text"] = "New item text:" },
		{ ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.2, ["letters"]=10,
		  ["defaultValue"] = function()
				return EngBotConfig["newItemText"];
			end,
		  ["func"] = function(v)
				EngBotConfig["newItemText"] = v;
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
	},
	{	-- Item count increased text
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.5, ["color"] = { 1,1,0.25 },
		  ["text"] = "Item count increased:" },
		{ ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.2, ["letters"]=10,
		  ["defaultValue"] = function()
				return EngBotConfig["newItemTextPlus"];
			end,
		  ["func"] = function(v)
				EngBotConfig["newItemTextPlus"] = v;
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
	},
	{	-- Item count decreased text
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.5, ["color"] = { 1,1,0.25 },
		  ["text"] = "Item count decreased:" },
		{ ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.2, ["letters"]=10,
		  ["defaultValue"] = function()
				return EngBotConfig["newItemTextMinus"];
			end,
		  ["func"] = function(v)
				EngBotConfig["newItemTextMinus"] = v;
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		},
	},
	{	-- New Tag timing
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.5, ["color"] = { 1,1,0.25 }, ["text"] = "Timeout for new tag - older (Minutes):" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.5, ["minValue"] = 0, ["maxValue"] = 60*6, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return ceil(EngBotConfig["newItemTimeout"] / 60);
			end,
		  ["func"] = function(v)
				EngBotConfig["newItemTimeout"] = tonumber(v) * 60;
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		}
	},
	{	-- New Tag timing
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.5, ["color"] = { 1,1,0.25 }, ["text"] = "Timeout for new tag - newer (Minutes):" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.5, ["minValue"] = 0, ["maxValue"] = 60*1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return ceil(EngBotConfig["newItemTimeout2"] / 60);
			end,
		  ["func"] = function(v)
				EngBotConfig["newItemTimeout2"] = tonumber(v) * 60;
				EngBot_SetDefaultValues(0);
				EngBot_window_update_required = EngBot_MANDATORY;
				EngBot_UpdateWindow();
			end
		}
	},


	{},	---------------------------------------------------------------------------------------
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = { 1,0,0.25 }, ["align"] = "center",
		  ["text"] = "Bag Hooks" },
	},
	{},	---------------------------------------------------------------------------------------
	{	-- Hook "Bot"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Bot:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["hook_BANKFRAME_OPENED"];
			end,
		  ["func"] = function(v)
				EngBotConfig["hook_BANKFRAME_OPENED"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bot"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bot:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag-1"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag-1"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},
	{	-- Show "Bag 5"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 1 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag5"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag5"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bag 6"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 2 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag6"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag6"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bag 7"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 3 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag7"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag7"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bag 8"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 4 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag8"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag8"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bag 9"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 5 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag9"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag9"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Show "Bag 10"
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Include Bag 6 Contents:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["show_Bag10"];
			end,
		  ["func"] = function(v)
				EngBotConfig["show_Bag10"] = tonumber(v);
				EngBot_SetDefaultValues(0);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{},	---------------------------------------------------------------------------------------
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = { 1,0,0.25 }, ["align"] = "center",
		  ["text"] = "Misc Options" },
	},
	{},	---------------------------------------------------------------------------------------
	{	-- Build trade skill list for export
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Build trade skill list for export:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Off" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["build_trade_list"];
			end,
		  ["func"] = function(v)
				EngBotConfig["build_trade_list"] = tonumber(v);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "On" }
	},

	{	-- Tooltip Mode Setting
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.4, ["color"] = { 1,1,0.25 }, ["text"] = "Tooltip Mode:" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "right", ["text"] = "Mode 1" },
		{ ["type"] = "Slider", ["ID"] = 1, ["width"] = 0.4, ["minValue"] = 0, ["maxValue"] = 1, ["valueStep"] = 1,
		  ["defaultValue"] = function()
				return EngBotConfig["tooltip_mode"];
			end,
		  ["func"] = function(v)
				EngBotConfig["tooltip_mode"] = tonumber(v);
			end
		},
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.1, ["color"] = { 0,1,0.5 }, ["align"] = "left", ["text"] = "Mode 2" }
	},


	{},	---------------------------------------------------------------------------------------
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 1.0, ["color"] = { 1,0,0.25 }, ["align"] = "center",
		  ["text"] = "Item Search and Assignment" },
	},
	{},	---------------------------------------------------------------------------------------
	{
		{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.025+0.025+0.025 + 0.005, ["color"] = { 1,0,0.25 }, ["text"] = "" },
		{ ["type"] = "Text", ["ID"] = 2, ["width"] = 0.20, ["color"] = { 1,0,0.25 }, ["text"] = "Category" },
		{ ["type"] = "Text", ["ID"] = 3, ["width"] = 0.20, ["color"] = { 1,0,0.25 }, ["text"] = "Keywords" },
		{ ["type"] = "Text", ["ID"] = 4, ["width"] = 0.35, ["color"] = { 1,0,0.25 }, ["text"] = "Tooltip Search" },
		{ ["type"] = "Text", ["ID"] = 5, ["width"] = 0.170, ["color"] = { 1,0,0.25 }, ["text"] = "ItemType" }
	}
};


--EngBot_ConfigOptions = EngBot_ConfigOptions_Default;

function EngBot_Config_GetItemSearchList(key, idx)
	return EngBotConfig["item_search_list"][key][idx]
end
function EngBot_Config_AssignItemSearchList(v, key, idx)
	if (key ~= nil) then
		EngBotConfig["item_search_list"][key][idx] = v;
	end
end

function EngBot_Config_GetItemSearchListLower(key, idx)
	return string.lower(EngBotConfig["item_search_list"][key][idx]);
end
function EngBot_Config_AssignItemSearchListUpper(v, key, idx)
	if (key ~= nil) then
		EngBotConfig["item_search_list"][key][idx] = string.upper(v);
	end
end

function EngBot_Config_SwapSearchListItems(unused_value, key1, key2)
	local tmp;

	if ( (EngBotConfig["item_search_list"][key1] ~= nil) and (EngBotConfig["item_search_list"][key2] ~= nil) ) then
		tmp = EngBotConfig["item_search_list"][key1];
		EngBotConfig["item_search_list"][key1] = EngBotConfig["item_search_list"][key2];
		EngBotConfig["item_search_list"][key2] = tmp;

		if (key1 > key2) then
			EngBot_Opts_CurrentPosition = EngBot_Opts_CurrentPosition - 1;
		else
			EngBot_Opts_CurrentPosition = EngBot_Opts_CurrentPosition + 1;
		end

		EngBot_Options_UpdateWindow();
	end
end

function EngBot_CreateConfigOptions()
	local key,value;

	EngBot_ConfigOptions = EngBot_ConfigOptions_Default;

	for key,value in EngBotConfig["item_search_list"] do
		table.insert( EngBot_ConfigOptions,
			{
{ ["type"] = "Text", ["ID"] = 1, ["width"] = 0.025, ["color"] = { 1,0,1 }, ["text"] = key.."." },
{ ["type"] = "UpButton", ["ID"] = 1, ["width"] = 0.025,
  ["param1"] = key, ["param2"] = key-1,
  ["func"] = EngBot_Config_SwapSearchListItems
},
{ ["type"] = "DownButton", ["ID"] = 1, ["width"] = 0.025,
  ["param1"] = key, ["param2"] = key+1,
  ["func"] = EngBot_Config_SwapSearchListItems
},
{ ["type"] = "Edit", ["ID"] = 1, ["width"] = 0.20, ["letters"]=50, ["param1"] = key, ["param2"] = 1,
  ["defaultValue"] = EngBot_Config_GetItemSearchListLower, ["func"] = EngBot_Config_AssignItemSearchListUpper
},
{ ["type"] = "Edit", ["ID"] = 2, ["width"] = 0.20, ["letters"]=50, ["param1"] = key, ["param2"] = 2,
  ["defaultValue"] = EngBot_Config_GetItemSearchListLower, ["func"] = EngBot_Config_AssignItemSearchListUpper
},
{ ["type"] = "Edit", ["ID"] = 3, ["width"] = 0.35, ["letters"]=50, ["param1"] = key, ["param2"] = 3,
  ["defaultValue"] = EngBot_Config_GetItemSearchList, ["func"] = EngBot_Config_AssignItemSearchList
},
{ ["type"] = "Edit", ["ID"] = 4, ["width"] = 0.175, ["letters"]=50, ["param1"] = key, ["param2"] = 4,
  ["defaultValue"] = EngBot_Config_GetItemSearchList, ["func"] = EngBot_Config_AssignItemSearchList
}
			}  );

	end

end

------------------------

function EngBot_CalcButtonSize(newsize)
	local k = "button_size_opts";
	-- constants
	EngBags_BUTTONFRAME_X_PADDING = 2;
	EngBags_BUTTONFRAME_Y_PADDING = 1;
	EngBags_BUTTONFRAME_BUTTONWIDTH = newsize;
	EngBags_BUTTONFRAME_BUTTONHEIGHT = newsize;
	EngBags_BUTTONFRAME_WIDTH = EngBags_BUTTONFRAME_BUTTONWIDTH + (EngBags_BUTTONFRAME_X_PADDING*2);
	EngBags_BUTTONFRAME_HEIGHT = EngBags_BUTTONFRAME_BUTTONHEIGHT + (EngBags_BUTTONFRAME_Y_PADDING*2);
	EngBags_BKGRFRAME_WIDTH = EngBags_BUTTONFRAME_BUTTONWIDTH * 1.6;
	EngBags_BKGRFRAME_HEIGHT = EngBags_BUTTONFRAME_BUTTONHEIGHT * 1.6;
	EngBags_COOLDOWN_SCALE = 0.02125 * EngBags_BUTTONFRAME_BUTTONWIDTH;

	if (EngBotConfig[k] == nil) then
		EngBotConfig[k] = {
			["EngBags_BUTTONFONTHEIGHT"] = 0.35 * EngBags_BUTTONFRAME_BUTTONHEIGHT,
			["EngBags_BUTTONFONTHEIGHT2"] = 0.30 * EngBags_BUTTONFRAME_BUTTONHEIGHT,
			["EngBot_BUTTONFONTDISTANCE_Y"] = (0.08 * EngBags_BUTTONFRAME_WIDTH),
			["EngBot_BUTTONFONTDISTANCE_X"] = (0.10 * EngBags_BUTTONFRAME_HEIGHT)
		};

		if (newsize == 40) then
			EngBotConfig[k]["EngBags_BUTTONFONTHEIGHT"] = 14;
			EngBotConfig[k]["EngBags_BUTTONFONTHEIGHT2"] = 12;
			EngBotConfig[k]["EngBot_BUTTONFONTDISTANCE_Y"] = 2;
			EngBotConfig[k]["EngBot_BUTTONFONTDISTANCE_X"] = 5;
		end
	end

	EngBags_BUTTONFONTHEIGHT = math.ceil(EngBotConfig[k]["EngBags_BUTTONFONTHEIGHT"]);
	EngBags_BUTTONFONTHEIGHT2 = math.ceil(EngBotConfig[k]["EngBags_BUTTONFONTHEIGHT2"]);
	EngBot_BUTTONFONTDISTANCE_Y = EngBotConfig[k]["EngBot_BUTTONFONTDISTANCE_Y"];
	EngBot_BUTTONFONTDISTANCE_X = EngBotConfig[k]["EngBot_BUTTONFONTDISTANCE_X"];
end

-- scan the config and build a list of catagories
function EngBot_Catagories(exclude_list, select_bar)
	local clist, key, value;

	clist = {};

	for key,value in EngBotConfig do
		if ( (string.find(key, "putinslot--")) and (not string.find(key, "__version")) ) then
			barclass = string.sub(key, 12);

			if ( (exclude_list ~= nil) and (not exclude_list[barclass]) ) then
				if ( (select_bar == nil) or (value==select_bar) ) then
					table.insert(clist, barclass);
				end
			end
		end
	end

	table.sort(clist);

	return(clist);
end


-- sets a default value in the config if the current value is nil.  Increment "resetversion" to override saved values
-- and force a new setting.
function EBot_SetDefault(varname, defaultvalue, resetversion, cleanupfunction, cleanup_param1, cleanup_param2)
	EngBotConfig = EngBagsConfig["Bot"][EngBot_PLAYERID];
	local orig_value = EngBotConfig[varname];

if (orig_value == nil) then
		orig_value = "";
	end

        if (resetversion == nil) then
                -- more debugging
                message("* Warning, EngBot EBot_SetDefault called with nil reset version: "..varname.." *");
                resetversion = 0;
        end

        if (cleanupfunction ~= nil) then
                EngBotConfig[varname] = cleanupfunction(EngBotConfig[varname], cleanup_param1, cleanup_param2);
        end

        if (EngBotConfig[varname] == nil) then
                EngBotConfig[varname] = defaultvalue;
        elseif (EngBotConfig[varname.."__version"] == nil) then
                EngBotConfig[varname] = defaultvalue;
        elseif (EngBotConfig[varname.."__version"] < resetversion) then
		EngBags_PrintDEBUG("old version: "..EngBotConfig[varname.."__version"]..", resetversion: "..resetversion);
                EngBags_Print( varname.." was reset to it's default value.  Changed from '"..orig_value.."' to "..EngBotConfig[varname], 1,0,0 );
                EngBotConfig[varname] = defaultvalue;
        end

        EngBotConfig[varname.."__version"] = resetversion;
end


function EBags_SetDefault(varname, defaultvalue, resetversion, cleanupfunction, cleanup_param1, cleanup_param2)
	local orig_value = EngBagsConfig[varname];

if (orig_value == nil) then
		orig_value = "";
	end

        if (resetversion == nil) then
                -- more debugging
                message("* Warning, EngBot EBags_SetDefault called with nil reset version: "..varname.." *");
                resetversion = 0;
        end

        if (cleanupfunction ~= nil) then
                EngBagsConfig[varname] = cleanupfunction(EngBagsConfig[varname], cleanup_param1, cleanup_param2);
        end

        if (EngBagsConfig[varname] == nil) then
                EngBagsConfig[varname] = defaultvalue;
        elseif (EngBotConfig[varname.."__version"] == nil) then
                EngBagsConfig[varname] = defaultvalue;
        elseif (EngBotConfig[varname.."__version"] < resetversion) then
		EngBags_PrintDEBUG("old version: "..EngBotConfig[varname.."__version"]..", resetversion: "..resetversion);
                EngBags_Print( varname.." was reset to it's default value.  Changed from '"..orig_value.."' to "..EngBagsConfig[varname], 1,0,0 );
                EngBagsConfig[varname] = defaultvalue;
        end

        EngBotConfig[varname.."__version"] = resetversion;
end

function EngBot_SetClassBars()
	local c = {};
	local localizedPlayerClass, englishClass = UnitClass("player");

	c["WARLOCK"] = "";
	c["MAGE"] = "";
	c["PRIEST"] = "";
	c["HUNTER"] = "";
	c["ROGUE"] = "";
	c["SHAMAN"] = "";
	c["DRUID"] = "";
	c["WARRIOR"] = "";
	c["PALADIN"] = "";

	c[englishClass] = "putinslot--CLASS_ITEMS";

	EngBotConfig["putinslot--SOULSHARDS"] = c["WARLOCK"].."1";
	EngBotConfig["putinslot--WARLOCK_REAGENTS"] = c["WARLOCK"].."2";

	EngBotConfig["putinslot--ROGUE_POISON"] = c["ROGUE"].."1";
	EngBotConfig["putinslot--ROGUE_POWDER"] = c["ROGUE"].."1";

	EngBotConfig["putinslot--MAGE_REAGENT"] = c["MAGE"].."1";

	EngBotConfig["putinslot--SHAMAN_REAGENTS"] = c["SHAMAN"].."1";
end

-- set "re" to 1 to restore all default values
function EngBot_SetDefaultValues(re)
        local i, key, value, newEngBotConfig;

	local current_config_version = 2;	-- increase this number to wipe everyone's settings

        if ( (EngBotConfig == nil) or (EngBotConfig["configVersion"] == nil) or (EngBotConfig["configVersion"] ~= current_config_version) ) then
                EngBotConfig = { ["configVersion"] = current_config_version };
        end

	EBot_SetDefault("tooltip_mode", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("hide_bag_icons", 0, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("hide_purchase button", 0, 1+re, EngBags_NumericRange, 0, 1);

        EBot_SetDefault("maxColumns", 9, 1+re, EngBags_NumericRange, EngBags_MAXCOLUMNS_MIN,EngBags_MAXCOLUMNS_MAX);

        EBot_SetDefault("moveLock", 1, 1+re, EngBags_NumericRange, 0,1);

	EBot_SetDefault("hook_BANKFRAME_OPENED", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag-1", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag5", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag6", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag7", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag8", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag9", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("show_Bag10", 1, 1+re, EngBags_NumericRange, 0, 1);

	EBot_SetDefault("frameButtonSize", 40, 1+re, EngBags_NumericRange, 15, 80);

	EngBot_CalcButtonSize(EngBotConfig["frameButtonSize"]);

        EBot_SetDefault("frameLEFT", UIParent:GetRight() * UIParent:GetScale() * 0.5, 2+re, EngBags_NumericRange);
        EBot_SetDefault("frameRIGHT", UIParent:GetRight() * UIParent:GetScale() * 0.975, 2+re, EngBags_NumericRange);
        EBot_SetDefault("frameTOP", UIParent:GetTop() * UIParent:GetScale() * 0.90, 2+re, EngBags_NumericRange);
        EBot_SetDefault("frameBOTTOM", UIParent:GetTop() * UIParent:GetScale() * 0.19, 2+re, EngBags_NumericRange);
        EBot_SetDefault("frameXRelativeTo", "RIGHT", 1+re, EngBags_StringChoices, {"RIGHT","LEFT"} );
        EBot_SetDefault("frameYRelativeTo", "BOTTOM", 1+re, EngBags_StringChoices, {"TOP","BOTTOM"} );

	EBot_SetDefault("frameXSpace", 5, 1+re, EngBags_NumericRange, 0, 20);
        EBot_SetDefault("frameYSpace", 5, 1+re, EngBags_NumericRange, 0, 20);

	EBot_SetDefault("show_top_graphics", 1, 1+re, EngBags_NumericRange, 0, 1);
	EBot_SetDefault("build_trade_list", 0, 1+re, EngBags_NumericRange, 0, 1);

        EBot_SetDefault("newItemText", "*New*", 1+re);
        EBot_SetDefault("newItemTextPlus", "++", 1+re);
        EBot_SetDefault("newItemTextMinus", "--", 1+re);
	EBot_SetDefault("newItemText_Off", "", 1+re);
        EBot_SetDefault("newItemTimeout", 60*60*3 , 1+re, EngBags_NumericRange);     -- 3 hours for an item to lose "new" status
        EBot_SetDefault("newItemTimeout2", 60*10 , 1+re, EngBags_NumericRange);      -- 10 minutes
        EBot_SetDefault("newItemColor1_R", 0.9 , 1+re, EngBags_NumericRange, 0, 1.0);
        EBot_SetDefault("newItemColor1_G", 0.9 , 1+re, EngBags_NumericRange, 0, 1.0);
        EBot_SetDefault("newItemColor1_B", 0.2 , 1+re, EngBags_NumericRange, 0, 1.0);
        EBot_SetDefault("newItemColor2_R", 0.0 , 1+re, EngBags_NumericRange, 0, 1.0);
        EBot_SetDefault("newItemColor2_G", 1.0 , 1+re, EngBags_NumericRange, 0, 1.0);
        EBot_SetDefault("newItemColor2_B", 0.4 , 1+re, EngBags_NumericRange, 0, 1.0);

	for i = 1, EngBags_MAINWINDOWCOLORIDX do
		EBot_SetDefault("bar_colors_"..i.."_background_r", 0.5, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_background_g", 0.0, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_background_b", 0.0, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_background_a", 0.5, 1+re, EngBags_NumericRange, 0, 1.0);

		EBot_SetDefault("bar_colors_"..i.."_border_r", 1.0, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_border_g", 0.0, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_border_b", 0.0, 1+re, EngBags_NumericRange, 0, 1.0);
		EBot_SetDefault("bar_colors_"..i.."_border_a", 0.5, 1+re, EngBags_NumericRange, 0, 1.0);
	end

	EngBot_SetClassBars();

        -- default slot locations for items
	EBot_SetDefault("putinslot--CLASS_ITEMS1", 15, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--EMPTY_PROJECTILE_SLOTS", 15, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--USED_PROJECTILE_SLOTS", 15, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--PROJECTILE", 14, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);          -- arrows and bullets that AREN'T in your shot bags
        EBot_SetDefault("putinslot--EMPTY_SLOTS", 13, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);         -- Empty slots go in this bar
        EBot_SetDefault("putinslot--GRAY_ITEMS", 13, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);          -- Gray items go in this bar
        --
        EBot_SetDefault("putinslot--OTHERORUNKNOWN", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);      -- if not soulbound, but doesn't match any other catagory, it goes here
        EBot_SetDefault("putinslot--TRADEGOODS", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--RECIPE", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--PATTERN", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--SCHEMATIC", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--FORMULA", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--TRADESKILL_COOKING", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--TRADESKILL_FIRSTAID", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--OTHERSOULBOUND", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);       -- this will usually be soulbound equipment
	EBot_SetDefault("putinslot--CUSTOM_01", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CUSTOM_02", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CUSTOM_03", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CUSTOM_04", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CUSTOM_05", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CUSTOM_06", 10, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	--
        EBot_SetDefault("putinslot--CONSUMABLE", 9, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--TRADESKILL_2", 8, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--TRADESKILL_1", 8, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--TRADESKILL_2_CREATED", 8, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--TRADESKILL_1_CREATED", 8, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--EQUIPPED", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        --
        EBot_SetDefault("putinslot--FOOD", 6, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--DRINK", 5, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--QUESTITEMS", 4, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        --
        EBot_SetDefault("putinslot--HEALINGPOTION", 3, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--HEALTHSTONE", 3, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--MANAPOTION", 2, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--BANDAGE", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--REAGENT", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--JUJU", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--MISC", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--TRADETOOLS", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--MINIPET", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--HEARTH", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
        EBot_SetDefault("putinslot--KEYS", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--CLASS_ITEMS2", 1, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);

	-- NEW EQUIP SORTING
	EBot_SetDefault("putinslot--BOP_BOE", 12, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPSHIRT", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPSHOULDER", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPLEGS", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPFEET", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPFINGER", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPWRIST", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPTABARD", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPBACK", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPCHEST", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPHEAD", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPNECK", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPHANDS", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPWAIST", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPTRINKET", 11, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPFIRERESIST", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPFROSTRESIST", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPSHADOWRESIST", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPNATURERESIST", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);
	EBot_SetDefault("putinslot--EQUIPARCANERESIST", 7, 1+re, EngBags_NumericRange, 1, EngBags_MAX_BARS);

        -- default item overrides
	EBot_SetDefault("itemoverride_loaddefaults", 1, 3+re, EngBags_NumericRange, 0, 1);
	if (EngBotConfig["itemoverride_loaddefaults"] == 1) then
		EngBotConfig["item_overrides"] = EngBags_DefaultItemOverrides;
		EngBotConfig["item_search_list"] = EngBags_DefaultSearchList;

		for key,value in EngBotConfig["item_search_list"] do
			if (string.sub(value[4], 1, 5) == "loc::") then
				EngBotConfig["item_search_list"][key][4] = EBLocal[ string.sub(value[4],6) ];
			end
		end

		for key,value in EBLocal["string_searches"] do
			table.insert(EngBotConfig["item_search_list"], EngBags_DefaultSearchItemsINSERTTO,
				{ value[1], "", value[2], "" } );
		end

		EngBotConfig["itemoverride_loaddefaults"] = 0;
	end

	-- cleanup old overrides that shouldn't be in the config anymore
	newEngBotConfig = EngBotConfig;
	for key,value in EngBotConfig do
		if (string.find(key, "itemoverride--")) then
			newEngBotConfig = EngBags_Table_RemoveKey(newEngBotConfig, key);
		end
	end
	EngBotConfig = newEngBotConfig;

        -- default sort views / default "allow new items in bar" settings
        EBot_SetDefault("bar_sort_"..EngBotConfig["putinslot--EMPTY_SLOTS"], EngBags_SORTBYNAMEREV, 2+re, EngBags_NumericRange, EngBags_SORTLOWESTVALUE, EngBags_SORTHIGHESTVALUE);
        EBot_SetDefault("bar_sort_"..EngBotConfig["putinslot--HEALINGPOTION"], EngBags_SORTBYNAMEREV, 2+re, EngBags_NumericRange, EngBags_SORTLOWESTVALUE, EngBags_SORTHIGHESTVALUE);
        EBot_SetDefault("bar_sort_"..EngBotConfig["putinslot--MANAPOTION"], EngBags_SORTBYNAMEREV, 2+re, EngBags_NumericRange, EngBags_SORTLOWESTVALUE, EngBags_SORTHIGHESTVALUE);
        EBot_SetDefault("bar_sort_"..EngBotConfig["putinslot--TRADEGOODS"], EngBags_SORTBYNAMEREV, 2+re, EngBags_NumericRange, EngBags_SORTLOWESTVALUE, EngBags_SORTHIGHESTVALUE);

	for i = 1, EngBags_MAX_BARS do
                EBot_SetDefault("bar_sort_"..i, EngBags_SORTBYNAME, 2+re, EngBags_NumericRange, EngBags_SORTLOWESTVALUE, EngBags_SORTHIGHESTVALUE);
		EBot_SetDefault("allow_new_in_bar_"..i, 1, 1+re, EngBags_NumericRange, 0, 1);
	end

	-- find matching catagories that are not assigned
	for key,value in EngBotConfig["item_search_list"] do
		if (EngBotConfig["putinslot--"..value[1]] == nil) then
			message("EngBot: Unassigned catagory: "..value[1].." -- It has been assigned to slot 1");
			EngBotConfig["putinslot--"..value[1]] = 1;
		end
	end

        if (re>0) then
                EngBot_SetDefaultValues(0);
        end
end

function EngBot_SetTradeSkills()
	local k,v;

	EngBot_TRADE1 = "";
	EngBot_TRADE2 = "";

	for k,v in EngBagsConfig[EngBot_PLAYERID]["tradeskills"] do
		if ((k ~= EBLocal["Cooking"]) and (k ~= EBLocal["First Aid"])) then
			EngBot_TRADE1 = EngBot_TRADE2;
			EngBot_TRADE2 = k;
		end
	end
end

function EngBot_init()
	EngBags_SetDefaultValues();
	EngBot_PLAYERID = "Bot";

	-- NOTE: Added keyring support.
	EngBagsItems[EngBot_PLAYERID][KEYRING_CONTAINER] = {};
	EngBagsItems[EngBot_PLAYERID][0] = {};
	EngBagsItems[EngBot_PLAYERID][1] = {};
	EngBagsItems[EngBot_PLAYERID][2] = {};
	EngBagsItems[EngBot_PLAYERID][3] = {};
	EngBagsItems[EngBot_PLAYERID][4] = {};

	-- change imported from auctioneer team..  what does it do?
	UIPanelWindows["EngBot_frame"] = { area = "left", pushable = 6 };

	if ( EngBot_WIPECONFIGONLOAD == 1 ) then
		EngBotConfig = {};
	end

        -- register slash command
        SlashCmdList["EngBot"] = EngBot_cmd;
        SLASH_EngBot1 = "/ebinv";
        SLASH_EngBot2 = "/eb";

    if ( EngBagsConfig["Bot"] == nil ) then
		EngBagsConfig["Bot"] = {};
	end

	if ( EngBagsConfig["Bot"][EngBot_PLAYERID] == nil ) then
		EngBagsConfig["Bot"][EngBot_PLAYERID] = {};
	end

        -- load default values
        EngBot_SetDefaultValues(0);

	-- go through the tradeskill list, and remove what shouldn't be there
	-- bah, do it in a lazy way, just wipe it
	if (EngBagsConfig[EngBot_PLAYERID] == nil) then
		EngBagsConfig[EngBot_PLAYERID] = {};
	end
	if (EngBagsConfig[EngBot_PLAYERID]["tradeskills"] == nil) then
		EngBagsConfig[EngBot_PLAYERID]["tradeskills"] = {};
	end
	local max_skills = 2;
	if (EngBagsConfig[EngBot_PLAYERID]["tradeskills"][EBLocal["Cooking"]] ~= nil) then
		max_skills = max_skills + 1;
	end
	if (EngBagsConfig[EngBot_PLAYERID]["tradeskills"][EBLocal["First Aid"]] ~= nil) then
		max_skills = max_skills + 1;
	end
	if (table.getn(EngBagsConfig[EngBot_PLAYERID]["tradeskills"]) > max_skills) then
		EngBagsConfig[EngBot_PLAYERID]["tradeskills"] = {};	-- wipe it out
		EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"] = {};
	end

	-- detailed info about tradeskills
	if (EngBagsConfig[EngBot_PLAYERID]["trades"] == nil) then
		EngBagsConfig[EngBot_PLAYERID]["trades"] = {};
	end

	EngBot_SetTradeSkills();

	EngBot_OnEvent("UPDATE_INVENTORY_ALERTS");	-- reload the items currently equipped

end

function EngBot_ClearForMode(mode)
    EngBot_Mode = mode
    EngBot_AtBot = 0;
    EngBot_frame:Hide();
    EngBot_lastItemNum = 1
    EngBagsItems[EngBot_PLAYERID] = {}
end

function EngBot_GetReloadQuery()
    local query = "c"
    if (EngBot_Mode == "bot_bank_item") then
        query = "bank";
    elseif (EngBot_Mode == "bot_mail_item") then
        query = "mail ?";
    end
    return query
end

function EngBot_OnEvent(event)
	if (event == "CHAT_MSG_WHISPER") then
        local message = arg1
        local sender = arg2
        local name = GetUnitName("target")
        if (message == "=== Bank ===") then
            EngBot_ClearForMode("bot_bank_item")
        end
        if (message == "=== Inventory ===") then
            EngBot_ClearForMode("bot_item")
        end
        if (message == "=== Mailbox ===") then
            EngBot_ClearForMode("bot_mail_item")
        end
        if (sender == name) then
			EngBot_AtBot = 1;
			EngBot_resort_required = EngBot_MANDATORY;
			EngBot_edit_mode = 0;
			if (EngBot_Mode == "bot_item") then
	   		    EngBotFrameTitleText:SetText(name.. "'s Inventory")
            elseif (EngBot_Mode == "bot_mail_item") then
                EngBotFrameTitleText:SetText(name.. "'s Mail")
			else
                EngBotFrameTitleText:SetText(name.. "'s Bank")
			end
			SetPortraitTexture(EngBot_framePortrait, "npc");
            EngBot_PlayerName = sender;
            EngBot_Add_item_cache(message);
            EngBot_UpdateWindow();
            if (EngBagsItems[EngBot_PLAYERID][1]) then
                for index,el in EngBagsItems[EngBot_PLAYERID][1] do
                    EngBot_frame:Show();
                    return
                end
            end
		end
	elseif (event == "TRADE_CLOSED" or event == "TRADE_UPDATE") then
        local name = GetUnitName("target")
        wait(1, function(command) SendChatMessage(command, "WHISPER", nil, GetUnitName("target")) end, EngBot_GetReloadQuery())
	elseif (event == "PLAYER_TARGET_CHANGED") then
        local name = GetUnitName("target")
        if (name ~= EngBot_PlayerName) then
            EngBot_AtBot = 0;
            EngBot_frame:Hide();
            EngBot_lastItemNum = 1
            EngBagsItems[EngBot_PLAYERID] = {}
        end
        EngBot_window_update_required = EngBot_MANDATORY;
        EngBot_UpdateWindow();

	end

	EngBags_PrintDEBUG("OnEvent: Finished "..event);
end

function EngBot_StartMoving(frame)
        if ( not frame.isMoving ) and ( EngBotConfig["moveLock"] == 1 ) then
                frame:StartMoving();
                frame.isMoving = true;
        end
end

function EngBot_StopMoving(frame)
        if ( frame.isMoving ) then
                frame:StopMovingOrSizing();
                frame.isMoving = false;

                -- save the position
                EngBotConfig["frameLEFT"] = frame:GetLeft() * frame:GetScale();
                EngBotConfig["frameRIGHT"] = frame:GetRight() * frame:GetScale();
                EngBotConfig["frameTOP"] = frame:GetTop() * frame:GetScale();
                EngBotConfig["frameBOTTOM"] = frame:GetBottom() * frame:GetScale();

                EngBags_PrintDEBUG("new position:  top="..EngBotConfig["frameTOP"]..", bottom="..EngBotConfig["frameBOTTOM"]..", left="..EngBotConfig["frameLEFT"]..", right="..EngBotConfig["frameRIGHT"] );
        end
end

function EngBot_OnMouseDown(button, frame)

	if ( button == "LeftButton" ) then
		EngBot_StartMoving(frame);
	elseif ( button == "RightButton" ) then
		HideDropDownMenu(1);
		EngBot_RightClickMenu_mode = "mainwindow";
		EngBot_RightClickMenu_opts = {};
		ToggleDropDownMenu(1, nil, EngBot_frame_RightClickMenu, "cursor", 0, 0);
	end

end


--	EngBot_resort_required: EngBot_NOTNEEDED, EngBot_REQUIRED, EngBot_MANDATORY
--	EngBot_window_update_required: EngBot_NOTNEEDED, EngBot_REQUIRED, EngBot_MANDATORY
--	EngBot_item_cache[ bag ][ slot ]
function EngBot_Add_item_cache(itemlink)

    if (not string.find(itemlink, "Hitem")) then
        return
    end

    local soulbound = false
    if (string.find(itemlink, "soulbound")) then
        itemlink = string.sub(itemlink, 0, string.find(itemlink, "soulbound") - 2)
        soulbound = true
    end

    local mailIndex = "0"
    if (string.find(itemlink, "#") == 1) then
        mailIndex = string.sub(itemlink, 2, string.find(itemlink, " "));
        itemlink = string.sub(itemlink, string.find(itemlink, " ") + 1)
    end

    local cnt = 1
    if (string.find(itemlink, "|h|rx")) then
        cnt = string.sub(itemlink, string.find(itemlink, "|h|rx") + 5)
        if (string.find(cnt, " ")) then
            cnt = string.sub(cnt, 0, string.find(cnt, " "))
        end
        itemlink = string.sub(itemlink, 0, string.find(itemlink, "|h|rx") + 3)
    end
    local st = string.find(itemlink, "Hitem:");
    local itemid = string.sub(itemlink, st + 6, string.find(itemlink, ":", st + 7) - 1);

	local bag, slot, index;	-- used as "for loop" counters
	local itm;		-- entry that will be written to the cache
	local update_suggested = 0;
	local resort_suggested = 0;
	local resort_mandatory = 0;
	-- variables used in outer loop, bag:
	local bagNumSlots;
	local is_shot_bag;
	-- variables used in inner loop, slots:
	local a,b,c,d;
	local sequencial_slot_num = 0;
	EngBot_item_cache = EngBagsItems[EngBot_PLAYERID];

    local bagnum = 1
    local slotnum = EngBot_lastItemNum;

    if (EngBot_item_cache[bagnum] == nil) then
        EngBot_item_cache[bagnum] = {}
    end

    for index,element in EngBot_item_cache[bagnum] do
        if (element and element["itemid"] == itemid) then
            return
        end
    end

    if (EngBot_item_cache[bagnum][slotnum] == nil) then
        EngBot_item_cache[bagnum][slotnum] = {}
    end

    itm = {
        ["itemlink"] = itemlink,
        ["itemid"] = itemid,
        ["bagnum"] = bagnum,
        ["slotnum"] = slotnum,
        ["sequencial_slot_num"] = slotnum,
        ["bagname"] = "Bot",
        ["iteminfo"] = itemlink,
        ["soulbound"] = soulbound,
        ["mailIndex"] = mailIndex,
        -- take items from old position
        ["bar"] = EngBot_item_cache[bagnum][slotnum]["bar"],
        ["button_num"] = EngBot_item_cache[bagnum][slotnum]["button_num"],
        ["indexed_on"] = EngBot_item_cache[bagnum][slotnum]["indexed_on"],
        ["display_string"] = EngBot_item_cache[bagnum][slotnum]["display_string"],
        ["barClass"] = EngBot_item_cache[bagnum][slotnum]["barClass"],
        ["button_num"] = EngBot_item_cache[bagnum][slotnum]["button_num"],	-- assigned when drawing
        ["keywords"] = EngBot_item_cache[bagnum][slotnum]["keywords"],
        ["itemlink_override_key"] = EngBot_item_cache[bagnum][slotnum]["itemlink_override_key"],
        -- misc junk
        ["search_match"] = EngBot_item_cache[bagnum][slotnum]["search_match"],
        ["gametooltip"] = EngBot_item_cache[bagnum][slotnum]["gametooltip"]
        };


    -- GameTooltip:SetHyperlink(itemlink);
    itm["itemname"], itm["itemlink2"], itm["itemRarity"], itm["itemMinLevel"], itm["itemtype"], itm["itemsubtype"], itm["itemstackcount"], itm["itemloc"], itm["texture"] = GetItemInfo(itemid);
    itm["itemcount"] = tonumber(cnt)
    itm["locked"] = 0
    itm["quality"] = itm["itemRarity"]
    itm["readable"] = 0
    itm["start"] = 0
    itm["duration"] = 0
    itm["enable"] = 1
    itm["keywords"] = {}
    itm["itemlink_noninstance"] = itemlink
    itm["itemlink_override_key"] = itemlink
    if (is_shot_bag) then
        itm["keywords"]["SHOT_BAG"]=1;
    end
    if (soulbound) then
        itm["keywords"]["SOULBOUND"] = 1
    end

    if (itm["bar"] == nil) then
        resort_mandatory = 1;
    end

    if (itm["itemsubtype"] == nil) then itm["itemsubtype"] = ""; end
    if (itm["itemname"] == nil) then itm["itemname"] = ""; end

    if (itm["locked"] ~= EngBot_item_cache[bagnum][slotnum]["locked"]) then
        update_suggested = 1;
    end

    if (
        (itm["itemlink"] ~= EngBot_item_cache[bagnum][slotnum]["itemlink"]) or
        (itm["keywords"]["SHOT_BAG"] ~= EngBot_item_cache[bagnum][slotnum]["keywords"]["SHOT_BAG"])
        ) then
        -- the item changed
        if (itm["indexed_on"] ~= nil) then
            resort_suggested = 1;
            itm["indexed_on"] = GetTime();
            itm["display_string"] = "newItemText";
        end
    else
        -- item has not changed, maybe the count did?
        if ( (itm["itemcount"] ~= EngBot_item_cache[bagnum][slotnum]["itemcount"]) and (EngBot_item_cache[bagnum][slotnum]["itemcount"] ~= nil) ) then
            update_suggested = 1;
            if (itm["itemcount"] < EngBot_item_cache[bagnum][slotnum]["itemcount"]) then
                itm["display_string"] = "newItemTextMinus";
            else
                itm["display_string"] = "newItemTextPlus";
            end
            itm["indexed_on"] = GetTime();
        end
    end

    if (itm["indexed_on"] == nil) then
        itm["indexed_on"] = 1;
        itm["display_string"] = "NewItemText_Off";

    end

    EngBot_item_cache[bagnum][slotnum] = itm;	-- save updated information
    EngBags_PrintDEBUG("put item"..itm["itemname"].."to"..bagnum.."/"..slotnum);
    -- bagNumSlots = 0, make sure you wipe the cache entry
    if (table.getn(EngBot_item_cache[bagnum]) ~= 0) then
        resort_mandatory = 1;
    end
    --EngBot_item_cache[bagnum] = {};
    EngBot_lastItemNum = EngBot_lastItemNum + 1

	if (resort_mandatory == 1) then
		EngBot_resort_required = EngBot_MANDATORY;
		EngBot_window_update_required = EngBot_MANDATORY;
	elseif (resort_suggested == 1) then
		EngBot_resort_required = math.max(EngBot_resort_required, EngBot_REQUIRED);
		EngBot_window_update_required = EngBot_MANDATORY;
	elseif (update_suggested == 1) then
		EngBot_window_update_required = EngBot_MANDATORY;
	end
end



-- Take an item and figure out what "bar" you want to place it in
--              return selected_bar, barClass;
function EngBot_PickBar(itm)
        if (itm["itemlink"] == nil) then
                if (itm["keywords"]["SHOT_BAG"]) then
			itm["bar"] = EngBotConfig["putinslot--EMPTY_PROJECTILE_SLOTS"];
			while (type(itm["bar"]) ~= "number") do
				itm["bar"] = EngBotConfig[itm["bar"]];
			end
			itm["barClass"] = "EMPTY_PROJECTILE_SLOTS";
                        return itm;
                else
			itm["bar"] = EngBotConfig["putinslot--EMPTY_SLOTS"];
			while (type(itm["bar"]) ~= "number") do
				itm["bar"] = EngBotConfig[itm["bar"]];
			end
			itm["barClass"] = "EMPTY_SLOTS";
                        return itm;
                end
        else
		-- vars used in tooltip creation
		local idx, tmptooltip, tmpval, tooltip_info_concat;
		-- vars used in array loops
		local key, value;
		local found;

		-- reset item keywords
		if (itm["keywords"]["SHOT_BAG"]) then
			itm["keywords"] = {
				["USED_PROJECTILE_SLOT"] = 1,	-- this indicates that the shot bag isn't empty
				["SHOT_BAG"] = 1
				};
		end
		if (itm["itemRarity"] ~= nil) then
			itm["keywords"]["ITEMRARITY_"..itm["itemRarity"]] = 1;
		end

		-- setup tradeskill keywords
		if ( (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"] ~= nil) and (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"][ itm["itemlink_noninstance"] ] ~= nil) ) then
			-- the item exists in our cache
			if (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"][ itm["itemlink_noninstance"] ][EngBot_TRADE1] ~= nil) then
				itm["keywords"]["TRADESKILL_1"] = 1;
			elseif (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"][ itm["itemlink_noninstance"] ][EngBot_TRADE2] ~= nil) then
				itm["keywords"]["TRADESKILL_2"] = 1;
			elseif (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"][ itm["itemlink_noninstance"] ][EBLocal["Cooking"]] ~= nil) then
				itm["keywords"]["TRADESKILL_COOKING"] = 1;
			elseif (EngBagsConfig[EngBot_PLAYERID]["tradeskill_items"][ itm["itemlink_noninstance"] ][EBLocal["First Aid"]] ~= nil) then
				itm["keywords"]["TRADESKILL_FIRSTAID"] = 1;
			end
		end

		-- setup tradeskill produced items keywords
		if ( (EngBagsConfig[EngBot_PLAYERID]["tradeskill_production"] ~= nil) and (EngBagsConfig[EngBot_PLAYERID]["tradeskill_production"][ itm["itemlink_noninstance"] ] ~= nil) ) then
			if (EngBagsConfig[EngBot_PLAYERID]["tradeskill_production"][ itm["itemlink_noninstance"] ][EngBot_TRADE1] ~= nil) then
				itm["keywords"]["TRADESKILL_1_CREATED"] = 1;
			elseif (EngBagsConfig[EngBot_PLAYERID]["tradeskill_production"][ itm["itemlink_noninstance"] ][EngBot_TRADE2] ~= nil) then
				itm["keywords"]["TRADESKILL_2_CREATED"] = 1;
			end
			-- not doing cooking or first aid.
		end

		-- setup equipped items keywords
		if ( EngBagsConfig[EngBot_PLAYERID]["equipped_items"] ~= nil ) then
			if (EngBagsConfig[EngBot_PLAYERID]["equipped_items"][ itm["itemlink_noninstance"] ] ~= nil) then
				itm["keywords"]["EQUIPPED"] = 1;
			end
		end

		-- Load tooltip
		EngBot_tt:SetOwner(UIParent, "ANCHOR_NONE");	-- this makes sure that tooltip.valid = true
		if itm["bagnum"] < 0 then
				EngBot_tt:SetInventoryItem("player", BotButtonIDToInvSlotID(itm["slotnum"]));
			else
				EngBot_tt:SetBagItem(itm["bagnum"],itm["slotnum"]);
		end

		idx = 1;
		tmptooltip = getglobal("EngBot_ttTextLeft"..idx);
		tooltip_info_concat = "";
		itm["gametooltip"] = {};
		repeat
			tmpval = tmptooltip:GetText();

			if (tmpval ~= nil) then
				tooltip_info_concat = tooltip_info_concat.." "..tmpval;
				itm["gametooltip"][idx] = tmpval;
			end

			idx=idx+1;
			tmptooltip = getglobal("EngBot_ttTextLeft"..idx);
		until (tmpval==nil) or (tmptooltip==nil);

		-- EngBags_PrintDEBUG("Tooltip Text: "..tooltip_info_concat);

		if (string.find(tooltip_info_concat, EBLocal["soulbound_search"] )) then
			itm["keywords"]["SOULBOUND"] = 1;
		end

		itm["barClass"] = nil;

		-- step 1, check item overrides
		if (itm["keywords"]["SOULBOUND"] == nil) then
			itm["itemlink_override_key"] = itm["itemlink_noninstance"];
		else
			itm["itemlink_override_key"] = itm["itemlink_noninstance"].."-SB";
		end

		-- load an item override
		itm["barClass"] = EngBotConfig["item_overrides"][itm["itemlink_override_key"]];
		if (itm["barClass"] ~= nil) then
			itm["search_match"] = "item_override found";

			itm["bar"] = EngBotConfig["putinslot--"..itm["barClass"]];
			while ( (itm["bar"] ~= nil) and (type(itm["bar"]) ~= "number") ) do
				itm["bar"] = EngBotConfig[itm["bar"]];
			end
			if (type(itm["bar"]) ~= "number") then
				itm["barClass"] = nil;
			end
		end

		if (itm["barClass"] == nil) then
			for key,value in EngBotConfig["item_search_list"] do
				if (value[1] ~= "") then
					local found = 1;

					-- value[1] == catagory to place it in

					-- check keywords
					if ( (value[2] ~= "") and (itm["keywords"][value[2]] == nil) ) then
						found = nil;
					end
					-- check tooltip
					if ( (value[3] ~= "") and (not string.find(tooltip_info_concat, value[3])) ) then
						found = nil;
					end
					-- check itemType
					if ( (value[4] ~= "") and (itm["itemtype"] ~= value[4]) ) then
						found = nil;
					end

					if (found) then
						itm["search_match"] = ""..key..": "..value[1];
						itm["barClass"] = value[1];
						itm["bar"] = EngBotConfig["putinslot--"..itm["barClass"]];
						while ( (itm["bar"] ~= nil) and (type(itm["bar"]) ~= "number") ) do
							itm["bar"] = EngBotConfig[itm["bar"]];
						end
						if (type(itm["bar"]) == "number") then
							break;
						else
							itm["barClass"] = nil;
						end
					end
				end
			end
		end

		if (itm["barClass"] == nil) then
			itm["barClass"] = "OTHERORUNKNOWN";

			itm["bar"] = EngBotConfig["putinslot--"..itm["barClass"]];
			while ( (itm["bar"] ~= nil) and (type(itm["bar"]) ~= "number") ) do
				itm["bar"] = EngBotConfig[itm["bar"]];
			end
			if (type(itm["bar"]) ~= "number") then
				itm["barClass"] = "UNKNOWN";
				itm["bar"] = 1;
			end
		end

                return itm;
        end
end


function EngBot_Sort_item_cache()
	local i;
	local bagnum, slotnum, index;
	-- variables used in outer loop
	local bagNumSlots;
	-- variables used in inner loop
	----- 2nd loop
	local barnum;

	--Print("Resorting Items");
	EngBot_item_cache = EngBagsItems[EngBot_PLAYERID];

	-- wipe the current bar positions table
	EngBot_bar_positions = {};
	for i = 1, EngBags_MAX_BARS do
		EngBot_bar_positions[i] = {};
	end

	for index, bagnum in ipairs(EngBot_Bags) do

	if EngBot_item_cache[bagnum] == nil then
		return;
	end

        bagNumSlots = table.getn(EngBot_item_cache[bagnum]);
        if (bagNumSlots > 0) then
            for slotnum = 1, bagNumSlots do
                EngBot_item_cache[bagnum][slotnum] = EngBot_PickBar( EngBot_item_cache[bagnum][slotnum] );

                table.insert( EngBot_bar_positions[ EngBot_item_cache[bagnum][slotnum]["bar"] ], { ["bagnum"]=bagnum, ["slotnum"]=slotnum } );
            end
        end
	end

        -- sort the cache now
        for barnum = 1, EngBags_MAX_BARS do
		local toggle;

		if (EngBotConfig["bar_sort_"..barnum] == EngBags_SORTBYNAME) then
			toggle=1
			elseif (EngBotConfig["bar_sort_"..barnum] == EngBags_SORTBYNAMEREV) then
			toggle=2
		end

                if (toggle==1 or toggle==2) then
                        table.sort(EngBot_bar_positions[barnum],
                                function(a,b)
                                        return  EngBot_item_cache[a["bagnum"]][a["slotnum"]]["barClass"]..
						EngBot_item_cache[a["bagnum"]][a["slotnum"]]["itemsubtype"]..
						EngBags_ReverseString(
							EngBot_item_cache[a["bagnum"]][a["slotnum"]]["itemname"],toggle)..
							string.format("%04s",EngBot_item_cache[a["bagnum"]][a["slotnum"]]["itemcount"]
							)
								>
                                                EngBot_item_cache[b["bagnum"]][b["slotnum"]]["barClass"]..
						EngBot_item_cache[b["bagnum"]][b["slotnum"]]["itemsubtype"]..
						EngBags_ReverseString(
							EngBot_item_cache[b["bagnum"]][b["slotnum"]]["itemname"],toggle)..
							string.format("%04s",EngBot_item_cache[b["bagnum"]][b["slotnum"]]["itemcount"]
							)
                                end);
                end
        end

	EngBot_resort_required = EngBot_NOTNEEDED;
	EngBot_window_update_required = EngBot_MANDATORY;
end


-- Make an inventory slot usable with the item specified in itm
-- cache entry is the array that comes directly from the cache
function EngBot_UpdateButton(itemframe, itm)
        local ic_start, ic_duration, ic_enable;
        local showSell = nil;
        local itemframe_texture = getglobal(itemframe:GetName().."IconTexture");
	local itemframe_normaltexture = getglobal(itemframe:GetName().."NormalTexture");
        local itemframe_font = getglobal(itemframe:GetName().."Count");
        local itemframe_stock = getglobal(itemframe:GetName().."Stock");
        local cooldownFrame = getglobal(itemframe:GetName().."_Cooldown");

        if ( EBLocal["_loaded"]==0 ) then
                return;
        end

        ic_start = 0;
        ic_duration = 0;
        ic_enable = nil;

        SetItemButtonTexture(itemframe, itm["texture"]);

        if ( EngBot_edit_mode == 1 ) then
                -- we should be hilighting an entire class of item
                if ( itm["barClass"] ~= EngBot_edit_hilight ) then
                        -- dim this item
                        itemframe_texture:SetVertexColor(1,1,1,0.15);
                        itemframe_font:SetVertexColor(1,1,1,0.5);
                else
                        -- hilight this item
                        itemframe_texture:SetVertexColor(1,1,0,1);
                        itemframe_font:SetVertexColor(1,1,0,1);
                end
        else
                -- no hilights, just do your normal work

                if ( (EngBotConfig["allow_new_in_bar_"..itm["bar"]] == 1) and (itm["itemlink"] ~= nil) and (itm["indexed_on"]>1) and ((GetTime()-itm["indexed_on"]) < EngBotConfig["newItemTimeout"]) ) then
                        -- item is still new, display the "new" text.
                        itemframe_stock:SetText( EngBotConfig[itm["display_string"]] );
                        if ( (GetTime()-itm["indexed_on"]) < EngBotConfig["newItemTimeout2"]) then
                                -- use color #2
                                itemframe_stock:SetTextColor(
                                        EngBotConfig["newItemColor2_R"],
                                        EngBotConfig["newItemColor2_G"],
                                        EngBotConfig["newItemColor2_B"] );
                                itemframe_font:SetVertexColor(
                                        EngBotConfig["newItemColor2_R"],
                                        EngBotConfig["newItemColor2_G"],
                                        EngBotConfig["newItemColor2_B"], 1 );
                        else

                                -- use color #1
                                itemframe_stock:SetTextColor(
                                        EngBotConfig["newItemColor1_R"],
                                        EngBotConfig["newItemColor1_G"],
                                        EngBotConfig["newItemColor1_B"] );
                                itemframe_font:SetVertexColor(
                                        EngBotConfig["newItemColor1_R"],
                                        EngBotConfig["newItemColor1_G"],
                                        EngBotConfig["newItemColor1_B"], 1 );
                        end
                        itemframe_stock:Show();
                        itemframe_texture:SetVertexColor(1,1,1,1);


		else
                        itemframe_stock:Hide();

                        if (EngBot_hilight_new == 1) then
                                itemframe_texture:SetVertexColor(1,1,1,0.15);
                                itemframe_font:SetVertexColor(1,1,1,0.5);
                        else
                                itemframe_texture:SetVertexColor(1,1,1,1);
                                itemframe_font:SetVertexColor(1,1,1,1);
                        end
                end


                if (itm["itemRarity"] == nil) then
			itemframe_normaltexture:SetVertexColor(0.4,0.4,0.4, 0.5);
                elseif (itm["itemRarity"] == 0) then     -- gray item
			itemframe_normaltexture:SetVertexColor(1,1,1,1);
                elseif (itm["itemRarity"] == 1) then     -- white item
			itemframe_normaltexture:SetVertexColor(0.4,0.4,0.4, 0.5);
                elseif (itm["itemRarity"] == 2) then     -- green item
			itemframe_normaltexture:SetVertexColor(0,1,0.25, 0.5);
                elseif (itm["itemRarity"] == 3) then     -- blue item
			itemframe_normaltexture:SetVertexColor(0.5,0.5,1, 0.5);
                elseif (itm["itemRarity"] == 4) then     -- purple item
			itemframe_normaltexture:SetVertexColor(1,0,1, 0.5);
                else    -- ?!
			itemframe_normaltexture:SetVertexColor(1,0,0, 0.5);
                end
        end

        SetItemButtonDesaturated(itemframe, itm["locked"], 0.5, 0.5, 0.5);
        SetItemButtonCount(itemframe, itm["itemcount"]);

	-- resize itemframe texture (this is the little border)
	itemframe_normaltexture:SetWidth(EngBags_BKGRFRAME_WIDTH);
	itemframe_normaltexture:SetHeight(EngBags_BKGRFRAME_HEIGHT);

	-- resize and position fonts
	--itemframe_font.font = "Interface\Addons\EngBags\DAB_CooldownFont.ttf";
	itemframe_font:SetTextHeight( EngBags_BUTTONFONTHEIGHT );	-- count, bottomright
	itemframe_font:ClearAllPoints();
	itemframe_font:SetPoint("BOTTOMRIGHT", itemframe:GetName(), "BOTTOMRIGHT", 0-EngBot_BUTTONFONTDISTANCE_X, EngBot_BUTTONFONTDISTANCE_Y );

	itemframe_stock.font = "Interface\Addons\EngBags\DAB_CooldownFont.ttf";
	itemframe_stock:SetTextHeight( EngBags_BUTTONFONTHEIGHT2 );	-- stock, topleft
	itemframe_stock:ClearAllPoints();
	itemframe_stock:SetPoint("TOPLEFT", itemframe:GetName(), "TOPLEFT", (EngBot_BUTTONFONTDISTANCE_X / 2), 0-EngBot_BUTTONFONTDISTANCE_Y );

        -- Set cooldown
        CooldownFrame_SetTimer(cooldownFrame, ic_start, ic_duration, ic_enable);
        if ( ( ic_duration > 0 ) and ( ic_enable == 0 ) ) then
                SetItemButtonTextureVertexColor(itemframe, 0.4, 0.4, 0.4);
        end

	cooldownFrame:SetScale(EngBags_COOLDOWN_SCALE);

end


function EngBot_GetBarPositionAndCache()
        local bar, position, itm;
	local bagnum, slotnum;

        if (EngBot_buttons[this:GetName()] ~= nil) then
                bar = EngBot_buttons[this:GetName()]["bar"];
                position = EngBot_buttons[this:GetName()]["position"];

		bagnum = EngBot_bar_positions[bar][position]["bagnum"];
		slotnum = EngBot_bar_positions[bar][position]["slotnum"];

                itm = EngBot_item_cache[bagnum][slotnum];

                return bar,position,itm;
        else
                return nil,nil,nil;
        end

end

function EngBot_ItemButton_OnEnter()
        local bar,position,itm = EngBot_GetBarPositionAndCache();

        if (EngBot_edit_selected == "") then
                EngBot_edit_hilight = itm["barClass"];
        end

        if ( not itm["itemlink"]) then
                if ( EngBot_edit_mode == 1 ) then
                        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
                        GameTooltip:ClearLines();
                        GameTooltip:AddLine("Empty Slot", 1,1,1 );

                        -- move by class
                        if (itm["barClass"] ~= nil) then
				if (EngBot_edit_selected ~= "") then
		                        GameTooltip:AddLine("|cFF00FF7FLeft click to move catagory |r"..EngBot_edit_selected.."|cFF00FF7F to bar |r"..bar, 1,0.25,0.5 );
				else
		                        GameTooltip:AddLine("|cFF00FF7FLeft click to select catagory to move:|r "..itm["barClass"], 1,0.25,0.5 );
					--GameTooltip:AddLine("Right click to assign this item to a different class", 1,0,0 );
				end
                        else
                                GameTooltip:AddLine("error: Item has no catagory", 1,0,0 );
                        end

                        GameTooltip:Show();
                else
                        GameTooltip:Hide();
                end
                if ( EngBot_edit_mode == 1 ) then
			-- redraw the window to show the hilighting of entire class items
			EngBot_window_update_required = EngBot_MANDATORY;
                        EngBot_UpdateWindow();
                end
                return;
        end


	-- Tool Tip Anchor: Anchor Right if the frame is on the left side of the screen else Anchor Left.

	if (EngBotConfig["frameLEFT"] < GetScreenWidth()/2) then
	        GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	else
		GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	end


    GameTooltip:SetHyperlink("item:"..itm["itemid"]..":0:0:0:0:0:0:0");

	-- Set Cooldown because BotBag (-1) is broke. Damn you Blizzard.
	if (itm["enable"] == 1) then
		itm["start"], itm["duration"], itm["enable"] = GetContainerItemCooldown(itm["bagnum"], itm["slotnum"]);
 			if (itm["duration"] > 0) then
				CoolDownString = EngBags_GetCooldownString(itm);
				GameTooltip:AddLine(CoolDownString, 1.0, 1.0, 1.0);
			end
	end
--[[
        if ( hasCooldown ) then
                this.updateTooltip = 1;
        else
                this.updateTooltip = nil;
        end
--]]
        if ( InRepairMode() and (repairCost and repairCost > 0) ) then
                GameTooltip:AddLine(TEXT(REPAIR_COST), 1, 1, 1);
                SetTooltipMoney(GameTooltip, repairCost);
                GameTooltip:Show();
        elseif ( MerchantFrame:IsVisible() ) then
                ShowContainerSellCursor(itm["bagnum"], itm["slotnum"]);
                EngBags_RegisterCurrentTooltipSellValue(GameTooltip, itm["bagnum"], itm["slotnum"], itm);
        elseif ( this.readable ) then
                ShowInspectCursor();
        end

        if ( EngBot_edit_mode == 1 ) then
                -- move by class
                if (itm["barClass"] ~= nil) then
			if (EngBot_edit_selected ~= "") then
				GameTooltip:AddLine("|cFF00FF7FLeft click to move catagory |r"..EngBot_edit_selected.."|cFF00FF7F to bar |r"..bar, 1,0.25,0.5 );
			else
				GameTooltip:AddLine(" ", 0,0,0);
				GameTooltip:AddLine("|cFF00FF7FLeft click to select catagory to move:|r "..itm["barClass"], 1,0.25,0.5 );
				GameTooltip:AddLine("Right click to assign this item to a different catagory", 1,0,0 );
				GameTooltip:AddLine(" ", 0,0,0);
			end
                else
                        GameTooltip:AddLine("Item has no catagory", 1,0,0 );
                end
        end

	if itm["bagname"] == nil then
		itm["bagname"] = "Bot";
	end

	GameTooltip:AddLine("Container::"..itm["bagname"], 1,0,0 );

        if ( EngBotConfig["tooltip_mode"] == 1 ) then
		EngBags_ModifyItemTooltip(itm["bagnum"], itm["slotnum"], "GameTooltip", itm);
	end

        if ( EngBot_edit_mode == 1 ) then
		-- redraw the window to show the hllighting of entire class items
		EngBot_window_update_required = EngBot_MANDATORY;
                EngBot_UpdateWindow();
        end

end

function EngBot_OnUpdate(elapsed)
        if ( not this.updateTooltip ) then
                return;
        end

        this.updateTooltip = this.updateTooltip - elapsed;
        if ( this.updateTooltip > 0 ) then
                return;
        end

        if ( GameTooltip:IsOwned(this) ) then
                EngBot_ItemButton_OnEnter();
        else
                this.updateTooltip = nil;
        end
end

function EngBot_ItemButton_OnLeave()
        EngBags_PrintDEBUG("EB_button: OnLeave()  this="..this:GetName() );

        if (EngBot_edit_selected == "") then
                EngBot_edit_hilight = "";
        end
        this.updateTooltip = nil;
        if ( GameTooltip:IsOwned(this) ) then
                GameTooltip:Hide();
                ResetCursor();
        end

        if ( EngBot_edit_mode == 1 ) then
		-- redraw the window to remove the hilighting of entire class items
		EngBot_window_update_required = EngBot_MANDATORY;
                EngBot_UpdateWindow();
        end
end

function EngBot_ItemButton_OnClick(button, ignoreShift)
        local bar, position, itm, bagnum, slotnum;

        bar = EngBot_buttons[this:GetName()]["bar"];
        position = EngBot_buttons[this:GetName()]["position"];

        bagnum = EngBot_bar_positions[bar][position]["bagnum"];
        slotnum = EngBot_bar_positions[bar][position]["slotnum"];

        itm = EngBot_item_cache[bagnum][slotnum];

        if ( button == "RightButton" ) then
            HideDropDownMenu(1);
            EngBot_RightClickMenu_mode = EngBot_Mode;
            EngBot_RightClickMenu_opts = {
                ["bar"] = bar,
                ["position"] = position,
                ["bagnum"] = bagnum,
                ["slotnum"] = slotnum
                };
            ToggleDropDownMenu(1, nil, EngBot_frame_RightClickMenu, this:GetName(), -50, 0);
            return
        end

        if (EngBot_edit_mode == 1) then
                -- don't do normal actions to this button, we're in edit mode
                if ( button == "LeftButton" ) then
                        if (EngBot_edit_selected == "") then
                                -- you clicked, we selected
                                EngBot_edit_selected = itm["barClass"];
                                EngBot_edit_hilight = itm["barClass"];
                        else
                                -- we got a click, and we already had one selected.  let's move the items
                                EngBotConfig["putinslot--"..EngBot_edit_selected] = bar;
				EngBot_resort_required = EngBot_MANDATORY;

                                EngBot_edit_selected = "";
                                EngBot_edit_hilight = itm["barClass"];

				-- resort will force a window update
                                EngBot_UpdateWindow();
                        end
		elseif ( button == "RightButton" ) then
			HideDropDownMenu(1);
			EngBot_RightClickMenu_mode = "item";
			EngBot_RightClickMenu_opts = {
				["bar"] = bar,
				["position"] = position,
				["bagnum"] = bagnum,
				["slotnum"] = slotnum
				};
			ToggleDropDownMenu(1, nil, EngBot_frame_RightClickMenu, this:GetName(), -50, 0);
                end
        else
                -- process normal clicks
		if (getglobal("AxuItemMenus_FillUtilityVariables") ~= nil) then
			if ( EngBot_DONT_CALL_AXUITEM == nil ) then
				if (AxuItemMenus_EvocationTest(button)) then
					AxuItemMenus_FillUtilityVariables(itm["bagnum"], itm["slotnum"]);
					AxuItemMenus_OpenMenu();
					return;
				end
			else
				if (getglobal("AxuItemMenus_EngBotHook") ~= nil) then
					if (AxuItemMenus_EngBotHook(itm["bagnum"], itm["slotnum"]) == 1) then
						return;
					end
				end
			end
		end

		-- process normal clicks
                if (itm) then
                        if ( button == "LeftButton" ) then
				if ( IsControlKeyDown() ) then
					DressUpItemLink(itm["itemlink"]);
				elseif ( IsShiftKeyDown() and not ignoreShift ) then
					if ( ChatFrameEditBox:IsVisible() ) then
						ChatFrameEditBox:Insert(itm["iteminfo"]);
					else
						--local texture, itemCount, locked, quality, readable = GetContainerItemInfo(itm["bag"], itm["slot"]);

						if ( not itm["locked"] ) then
							this.SplitStack = function(button, split)
								SplitContainerItem(itm["bagnum"], itm["slotnum"], split);
							end
							OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
						end
					end
				else
					--AllInOneInventory_HandleQuickMount(bag, slot);

					PickupContainerItem(itm["bagnum"], itm["slotnum"]);
				end
                        elseif ( button == "RightButton" ) then
                                if ( Cosmos_ShiftToSell == true ) then
                                        if ( MerchantFrame:IsVisible() ) then
                                                if ( IsShiftKeyDown() ) then
                                                        UseContainerItem(itm["bagnum"], itm["slotnum"]);
                                                end
                                        else
                                                UseContainerItem(itm["bagnum"], itm["slotnum"]);
                                        end
                                else
                                        if ( IsShiftKeyDown() and MerchantFrame:IsVisible() and not ignoreShift ) then
                                                this.SplitStack = function(button, split)
							local bar, position, bagnum, slotnum;

                                                        if (EngBot_buttons[this:GetName()] ~= nil) then
								bar = EngBot_buttons[this:GetName()]["bar"];
								position = EngBot_buttons[this:GetName()]["position"];

								bagnum = EngBot_bar_positions[bar][position]["bagnum"];
								slotnum = EngBot_bar_positions[bar][position]["slotnum"];

                                                                SplitContainerItem(bagnum, slotnum, split);
                                                                MerchantItemButton_OnClick("LeftButton");
                                                        end
                                                end
                                                OpenStackSplitFrame(this.count, this, "BOTTOMRIGHT", "TOPRIGHT");
                                        else
                                                UseContainerItem(itm["bagnum"], itm["slotnum"]);
                                        end
                                end
                        end
                end
		EngBot_window_update_required = EngBot_MANDATORY;
		EngBot_UpdateWindow();
        end
end

function EngBot_RightClick_PickupItem()
	local bagnum, slotnum;

	bagnum = this.value["bagnum"];
	slotnum = this.value["slotnum"];

	HideDropDownMenu(2);
	HideDropDownMenu(1);

	if ( (bagnum ~= nil) and (slotnum ~= nil) ) then
		PickupContainerItem(bagnum, slotnum);
	else
		message("Error, value not found.");
	end
end

function EngBot_Button_HighlightToggle_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	if (EngBot_hilight_new == 0) then
		EngBot_hilight_new = 1;
		EngBot_Button_HighlightToggle:SetText(EBLocal["EngBot_Button_HighlightToggle_on"]);
	else
		EngBot_hilight_new = 0;
		EngBot_Button_HighlightToggle:SetText(EBLocal["EngBot_Button_HighlightToggle_off"]);
	end
	EngBot_window_update_required = EngBot_MANDATORY;
	EngBot_UpdateWindow();
end

function EngBot_Button_ChangeEditMode_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	if (EngBot_edit_mode == 0) then
		EngBot_edit_mode = 1;
		EngBot_Button_ChangeEditMode:SetText(EBLocal["EngBot_Button_ChangeEditMode_MoveClass"]);
	else
		EngBot_edit_mode = 0;
		EngBot_Button_ChangeEditMode:SetText(EBLocal["EngBot_Button_ChangeEditMode_off"]);
	end
	EngBot_resort_required = EngBot_MANDATORY;
	-- resort will force a window redraw
	EngBot_UpdateWindow();
end

function EngBot_Button_MoveLockToggle_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	if (EngBotConfig["moveLock"] == 0) then
		EngBotConfig["moveLock"] = 1;
	else
		EngBotConfig["moveLock"] = 0;
	end
end

function EngBot_SlotTargetButton_OnClick(button, ignoreShift)
        local bar, tmp;

        if (EngBot_edit_mode == 1) then
                for tmp in string.gfind(this:GetName(), "EngBot_frame_SlotTarget_(%d+)") do
                        bar = tonumber(tmp);
                end

                if ( (bar == nil) or (bar < 1) or (bar > EngBags_MAX_BARS) ) then
                        return;
                end

                if ( button == "LeftButton" ) then

                        if (EngBot_edit_selected ~= "") then
                                -- we got a click, and we already had one selected.  let's move the items
                                EngBotConfig["putinslot--"..EngBot_edit_selected] = bar;

                                EngBot_edit_selected = "";
                                EngBot_edit_hilight = "";

				EngBot_resort_required = EngBot_MANDATORY;
				-- resort will force a window redraw as well
                                EngBot_UpdateWindow();
                        end

		elseif ( button == "RightButton" ) then

			HideDropDownMenu(1);
			EngBot_RightClickMenu_mode = "slot_target";
			EngBot_RightClickMenu_opts = {
				["bar"] = bar
				};
			ToggleDropDownMenu(1, nil, EngBot_frame_RightClickMenu, this:GetName(), -50, 0);

                end
        end
end

function EngBot_SlotTargetButton_OnEnter()
        local bar, tmp, key, value;

        if (EngBot_edit_mode == 1) then
                for tmp in string.gfind(this:GetName(), "EngBot_frame_SlotTarget_(%d+)") do
                        bar = tonumber(tmp);
                end

                if (EngBot_edit_selected ~= "") then
                        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
                        GameTooltip:ClearLines();
                        GameTooltip:AddLine("|cFF00FF7FLeft click to move catagory |r"..EngBot_edit_selected.."|cFF00FF7F to bar |r"..bar, 1,0.25,0.5 );
                        GameTooltip:Show();
                        return;
		else
                        GameTooltip:SetOwner(this, "ANCHOR_LEFT");
                        GameTooltip:ClearLines();
                        GameTooltip:AddLine("|cFF00FF7FBar |r"..bar, 1,0.25,0.5 );
			--GameTooltip:AddLine(" ");
			for key,value in EngBotConfig do
				if ( (string.find(key, "putinslot--")) and (value==bar) and (not string.find(key, "__version")) ) then
					barclass = string.sub(key, 12);
					GameTooltip:AddLine(barclass);
				end
			end
                        GameTooltip:Show();
			return;
                end
        end
        if ( GameTooltip:IsOwned(this) ) then
                GameTooltip:Hide();
                ResetCursor();
        end
end

function EngBot_SlotTargetButton_OnLeave()
        this.updateTooltip = nil;
        if ( GameTooltip:IsOwned(this) ) then
                GameTooltip:Hide();
                ResetCursor();
        end
end

function EngBot_SlotTargetButton_OnUpdate(elapsed)
        if ( not this.updateTooltip ) then
                return;
        end

        this.updateTooltip = this.updateTooltip - elapsed;
        if ( this.updateTooltip > 0 ) then
                return;
        end

        if ( GameTooltip:IsOwned(this) ) then
                EngBot_SlotTargetButton_OnEnter();
        else
                this.updateTooltip = nil;
        end
end

function EngBot_SetNewColor(previousValues)
	local r,g,b,opacity;

	r = nil;
	g = nil;
	b = nil;
	opacity = nil;

	if (this:GetName() == "ColorPickerFrame") then
		r,g,b = this:GetColorRGB();
		opacity = OpacitySliderFrame:GetValue();
	elseif (this:GetName() == "OpacitySliderFrame") then
		opacity = OpacitySliderFrame:GetValue();
	else
		if (previousValues ~= nil) then
			r = previousValues["r"];
			g = previousValues["g"];
			b = previousValues["b"];
			opacity = previousValues["opacity"];
		else
			return;
		end
	end

	if (UIDROPDOWNMENU_MENU_VALUE ~= nil) then
		if (r ~= nil) then
			EngBotConfig["bar_colors_"..(UIDROPDOWNMENU_MENU_VALUE["bar"]).."_"..(UIDROPDOWNMENU_MENU_VALUE["element"]).."_r"] = r;
		end
		if (g ~= nil) then
			EngBotConfig["bar_colors_"..(UIDROPDOWNMENU_MENU_VALUE["bar"]).."_"..(UIDROPDOWNMENU_MENU_VALUE["element"]).."_g"] = g;
		end
		if (b ~= nil) then
			EngBotConfig["bar_colors_"..(UIDROPDOWNMENU_MENU_VALUE["bar"]).."_"..(UIDROPDOWNMENU_MENU_VALUE["element"]).."_b"] = b;
		end
		if (opacity ~= nil) then
			EngBotConfig["bar_colors_"..(UIDROPDOWNMENU_MENU_VALUE["bar"]).."_"..(UIDROPDOWNMENU_MENU_VALUE["element"]).."_a"] = opacity;
		end
		EngBot_window_update_required = EngBot_MANDATORY;
		EngBot_UpdateWindow();
	end
end

function EngBot_RightClick_DeleteItemOverride()
	local bagnum, slotnum, itm;

	bagnum = this.value["bagnum"];
	slotnum = this.value["slotnum"];

	if ( (bagnum ~= nil) and (slotnum ~= nil) ) then
		itm = EngBot_item_cache[bagnum][slotnum];

		if ( (itm["itemlink_override_key"] ~= nil) and (EngBotConfig["item_overrides"][itm["itemlink_override_key"]] ~= nil) ) then
			EngBotConfig["item_overrides"] = EngBags_Table_RemoveKey(EngBotConfig["item_overrides"], itm["itemlink_override_key"] );
			HideDropDownMenu(1);
			EngBot_resort_required = EngBot_MANDATORY;
			-- resort will force a window redraw as well
			EngBot_UpdateWindow();
		end
	end
end

function EngBot_RightClick_SetItemOverride()
	local bagnum, slotnum, itm, new_barclass;

	bagnum = this.value["bagnum"];
	slotnum = this.value["slotnum"];
	new_barclass = this.value["barclass"];

	if ( (bagnum ~= nil) and (slotnum ~= nil) and (new_barclass ~= nil) ) then
		itm = EngBot_item_cache[bagnum][slotnum];

		EngBotConfig["item_overrides"][itm["itemlink_override_key"]] = new_barclass;
		HideDropDownMenu(2);
		HideDropDownMenu(1);
		EngBot_resort_required = EngBot_MANDATORY;
		EngBot_UpdateWindow();
	end
end

function EngBot_RightClick_Whisper()
    local bagnum, slotnum, itm, command;

    bagnum = this.value["bagnum"];
    slotnum = this.value["slotnum"];
    command = this.value["command"];

    if ( (bagnum ~= nil) and (slotnum ~= nil) ) then
        itm = EngBot_item_cache[bagnum][slotnum];
        if (command == "t ") then
            InitiateTrade("target")
            wait(1, function(cmd) SendChatMessage(cmd, "WHISPER", nil, GetUnitName("target")) end, command..itm["itemlink"])
        else
            local cmd = command..itm["itemlink"]
            if (itm["mailIndex"] ~= "0") then cmd = command..itm["mailIndex"] end
            SendChatMessage(cmd, "WHISPER", nil, GetUnitName("target"));
            wait(1, function(command) SendChatMessage(command, "WHISPER", nil, GetUnitName("target")) end, EngBot_GetReloadQuery())
        end
    end
end

function EngBot_frame_RightClickMenu_populate(level)
	local bar, position, bagnum, slotnum;
	local info, itm, barclass, tmp, checked, i;
	local key, value, key2, value2;


	-------------------------------------------------------------------------------------------------
	------------------------------- BOT ITEM CONTEXT MENU -----------------------------------------------
	-------------------------------------------------------------------------------------------------
	if (EngBot_RightClickMenu_mode == "bot_item") then
		-- we have a right click on a button

		bar = EngBot_RightClickMenu_opts["bar"];
		position = EngBot_RightClickMenu_opts["position"];
		bagnum = EngBot_bar_positions[bar][position]["bagnum"];
		slotnum = EngBot_bar_positions[bar][position]["slotnum"];
		itm = EngBot_item_cache[bagnum][slotnum];

        info = {
            ["text"] = "Add/Remove Trade",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="t " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

        info = { ["disabled"] = 1 };
        UIDropDownMenu_AddButton(info, level);

        info = {
            ["text"] = "Put to bank",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="bank " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

        info = {
            ["text"] = "Send by mail",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="sendmail " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

        info = { ["disabled"] = 1 };
        UIDropDownMenu_AddButton(info, level);

        info = {
            ["text"] = "Equip",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="e " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

        info = {
            ["text"] = "Use",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="u " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

	end

    -------------------------------------------------------------------------------------------------
    ------------------------------- BOT BANK ITEM CONTEXT MENU -----------------------------------------------
    -------------------------------------------------------------------------------------------------
    if (EngBot_RightClickMenu_mode == "bot_bank_item") then
        -- we have a right click on a button

        bar = EngBot_RightClickMenu_opts["bar"];
        position = EngBot_RightClickMenu_opts["position"];
        bagnum = EngBot_bar_positions[bar][position]["bagnum"];
        slotnum = EngBot_bar_positions[bar][position]["slotnum"];
        itm = EngBot_item_cache[bagnum][slotnum];

        info = {
            ["text"] = "Get from bank",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="bank -" },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

    end

    -------------------------------------------------------------------------------------------------
    ------------------------------- BOT MAIL ITEM CONTEXT MENU -----------------------------------------------
    -------------------------------------------------------------------------------------------------
    if (EngBot_RightClickMenu_mode == "bot_mail_item") then
        -- we have a right click on a button

        bar = EngBot_RightClickMenu_opts["bar"];
        position = EngBot_RightClickMenu_opts["position"];
        bagnum = EngBot_bar_positions[bar][position]["bagnum"];
        slotnum = EngBot_bar_positions[bar][position]["slotnum"];
        itm = EngBot_item_cache[bagnum][slotnum];

        info = {
            ["text"] = "Take",
            ["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["command"]="mail take " },
            ["func"] = EngBot_RightClick_Whisper
        };
        UIDropDownMenu_AddButton(info, level);

    end

	-------------------------------------------------------------------------------------------------
	------------------------------- ITEM CONTEXT MENU -----------------------------------------------
	-------------------------------------------------------------------------------------------------
	if (EngBot_RightClickMenu_mode == "item") then
		-- we have a right click on a button

		bar = EngBot_RightClickMenu_opts["bar"];
		position = EngBot_RightClickMenu_opts["position"];
		bagnum = EngBot_bar_positions[bar][position]["bagnum"];
		slotnum = EngBot_bar_positions[bar][position]["slotnum"];
		itm = EngBot_item_cache[bagnum][slotnum];

		if (level == 1) then
			-- top level of menu

			info = { ["text"] = itm["itemname"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
			UIDropDownMenu_AddButton(info, level);

			info = { ["disabled"] = 1 };
			UIDropDownMenu_AddButton(info, level);

			info = { ["text"] = "Current Catagory: "..itm["barClass"], ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
			UIDropDownMenu_AddButton(info, level);

			info = { ["disabled"] = 1 };
			UIDropDownMenu_AddButton(info, level);

			info = { ["text"] = "Assign item to catagory:", ["hasArrow"] = 1, ["value"] = "override_placement" };
			if (EngBotConfig["item_overrides"][itm["itemlink_override_key"]] ~= nil) then
				info["checked"] = 1;
			end
			UIDropDownMenu_AddButton(info, level);

			info = {
				["text"] = "Use default catagory assignment",
				["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum },
				["func"] = EngBot_RightClick_DeleteItemOverride
				};
			if (EngBotConfig["item_overrides"][itm["itemlink_override_key"]] == nil) then
				info["checked"] = 1;
			end
			UIDropDownMenu_AddButton(info, level);

			if (EngBot_SHOWITEMDEBUGINFO==1) then
				info = { ["disabled"] = 1 };
				UIDropDownMenu_AddButton(info, level);

				info = { ["text"] = "Debug Info: ", ["hasArrow"] = 1, ["value"] = "show_debug" };
				UIDropDownMenu_AddButton(info, level);
			end
		elseif (level == 2) then
			if ( this.value == "override_placement" ) then
				for i = EngBags_MAX_BARS, 1, -1 do
					info = {
						["text"] = "Catagories within bar "..i;
						["value"] = { ["opt"]="override_placement_select", ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["select_bar"]=i },
						["hasArrow"] = 1
						};
					if ( (EngBotConfig["item_overrides"][itm["itemlink_override_key"]] ~= nil) and (EngBotConfig["putinslot--"..EngBotConfig["item_overrides"][itm["itemlink_override_key"]]] == i) ) then
						info["checked"] = 1;
					end
					UIDropDownMenu_AddButton(info, level);
				end
			elseif ( this.value == "show_debug" ) then
				for key,value in itm do
					if (value == nil) then
						info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFFNil|r", ["notClickable"] = 1 };
						UIDropDownMenu_AddButton(info, level);
					else
						if ( (type(value) == "number") or (type(value) == "string") ) then
							info = { ["text"] = "|cFFFF7FFF"..key.."|r = |cFF007FFF"..value.."|r", ["notClickable"] = 1 };
							UIDropDownMenu_AddButton(info, level);
						else
							info = { ["text"] = "|cFFFF7FFF"..key.."|r|cFF338FFF=>Array()|r", ["notClickable"] = 1 };
							UIDropDownMenu_AddButton(info, level);
							for key2,value2 in value do
								info = { ["text"] = "    |cFFFF7FFF["..key2.."]|r = |cFF338FFF"..value2.."|r", ["notClickable"] = 1 };
								UIDropDownMenu_AddButton(info, level);
							end
						end
					end
				end
			end
		elseif (level == 3) then
			if ( this.value ~= nil ) then
				if ( this.value["opt"] == "override_placement_select" ) then
					for key,barclass in EngBot_Catagories(EngBot_Catagories_Exclude_List, this.value["select_bar"]) do
						info = {
							["text"] = barclass;
							["value"] = { ["bagnum"]=bagnum, ["slotnum"]=slotnum, ["barclass"]=barclass },
							["func"] = EngBot_RightClick_SetItemOverride
							};
						if (EngBotConfig["item_overrides"][itm["itemlink_override_key"]] == barclass) then
							info["checked"] = 1;
						end
						UIDropDownMenu_AddButton(info, level);
					end
				end
			end
		end

	-------------------------------------------------------------------------------------------------
	------------------------ SLOT TARGET CONTEXT MENU -----------------------------------------------
	-------------------------------------------------------------------------------------------------
	elseif (EngBot_RightClickMenu_mode == "slot_target") then
		-- right click on a slot
		bar = EngBot_RightClickMenu_opts["bar"];

		info = { ["text"] = "Bar "..bar, ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
		UIDropDownMenu_AddButton(info, level);

		info = { ["disabled"] = 1 };
		UIDropDownMenu_AddButton(info, level);

		for key,value in EngBotConfig do
			if ( (string.find(key, "putinslot--")) and (value==bar) and (not string.find(key, "__version")) ) then
				barclass = string.sub(key, 12);

				if ( type(value)=="number" ) then
					info = {
						["text"] = "Select: "..barclass;
						["value"] = barclass;
						["func"] = function()
								EngBot_edit_selected = (this.value);
								EngBot_edit_hilight = (this.value);
								EngBot_window_update_required = EngBot_MANDATORY;
								EngBot_UpdateWindow();
							end
						};
					UIDropDownMenu_AddButton(info, level);
				else
					info = {
						["text"] = "Select: "..barclass.." => "..value,
						["value"] = value;
						["func"] = function()
								EngBot_edit_selected = (this.value);
								EngBot_edit_hilight = (this.value);
								EngBot_window_update_required = EngBot_MANDATORY;
								EngBot_UpdateWindow();
							end
						};
					UIDropDownMenu_AddButton(info, level);
				end
			end
		end

		info = { ["disabled"] = 1 };
		UIDropDownMenu_AddButton(info, level);

		info = { ["text"] = "Sort Mode:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
		UIDropDownMenu_AddButton(info, level);

		for key,value in {
			[EngBags_NOSORT] = "No sort",
			[EngBags_SORTBYNAME] = "Sort by name",
			[EngBags_SORTBYNAMEREV] = "Sort last words first"
			} do

			if (EngBotConfig["bar_sort_"..bar] == key) then
				checked = 1;
			else
				checked = nil;
			end
			info = {
				["text"] = value;
				["value"] = { ["bar"]=bar, ["sortmode"]=key };
				["func"] = function()
						EngBotConfig["bar_sort_"..(this.value["bar"])] = (this.value["sortmode"]);
						EngBot_resort_required = EngBot_MANDATORY;
						EngBot_UpdateWindow();
					end,
				["checked"] = checked
				};
			UIDropDownMenu_AddButton(info, level);
		end

		info = { ["disabled"] = 1 };
		UIDropDownMenu_AddButton(info, level);

		info = { ["text"] = "Hilight new items:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
		UIDropDownMenu_AddButton(info, level);

		for key,value in {
			[0] = "Don't tag new items",
			[1] = "Tag new items"
			} do

			if (EngBotConfig["allow_new_in_bar_"..bar] == key) then
				checked = 1;
			else
				checked = nil;
			end

			info = {
				["text"] = value;
				["value"] = { ["bar"]=bar, ["value"]=key };
				["func"] = function()
						EngBotConfig["allow_new_in_bar_"..(this.value["bar"])] = (this.value["value"]);
						EngBot_resort_required = EngBot_MANDATORY;
						EngBot_UpdateWindow();
					end,
				["checked"] = checked
				};
			UIDropDownMenu_AddButton(info, level);
		end

		info = { ["disabled"] = 1 };
		UIDropDownMenu_AddButton(info, level);

		info = { ["text"] = "Color:", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
		UIDropDownMenu_AddButton(info, level);
		info = {
			["text"] = "Background Color",
			["hasColorSwatch"] = 1,
			["hasOpacity"] = 1,
			["r"] = EngBotConfig["bar_colors_"..bar.."_background_r"],
			["g"] = EngBotConfig["bar_colors_"..bar.."_background_g"],
			["b"] = EngBotConfig["bar_colors_"..bar.."_background_b"],
			["opacity"] = EngBotConfig["bar_colors_"..bar.."_background_a"],
			["notClickable"] = 1,
			["value"] = { ["bar"]=bar, ["element"] = "background" },
			["swatchFunc"] = EngBot_SetNewColor,
			["cancelFunc"] = EngBot_SetNewColor,
			["opacityFunc"] = EngBot_SetNewColor
			};
		UIDropDownMenu_AddButton(info, level);
		info = {
			["text"] = "Border Color",
			["hasColorSwatch"] = 1,
			["hasOpacity"] = 1,
			["r"] = EngBotConfig["bar_colors_"..bar.."_border_r"],
			["g"] = EngBotConfig["bar_colors_"..bar.."_border_g"],
			["b"] = EngBotConfig["bar_colors_"..bar.."_border_b"],
			["opacity"] = EngBotConfig["bar_colors_"..bar.."_border_a"],
			["notClickable"] = 1,
			["value"] = { ["bar"]=bar, ["element"] = "border" },
			["swatchFunc"] = EngBot_SetNewColor,
			["cancelFunc"] = EngBot_SetNewColor,
			["opacityFunc"] = EngBot_SetNewColor
			};
		UIDropDownMenu_AddButton(info, level);

	-------------------------------------------------------------------------------------------------
	------------------------ MAIN WINDOW CONTEXT MENU -----------------------------------------------
	-------------------------------------------------------------------------------------------------
	elseif (EngBot_RightClickMenu_mode == "mainwindow") then
		if (level == 1) then

			info = { ["text"] = "Ike3's EngBot @ EngBags", ["notClickable"] = 1, ["isTitle"] = 1, ["notCheckable"] = nil };
			UIDropDownMenu_AddButton(info, level);


			info = { ["disabled"] = 1 };
			UIDropDownMenu_AddButton(info, level);

			info = {
				["text"] = "Lock window",
				["value"] = nil,
				["func"] = EngBot_Button_MoveLockToggle_OnClick
				};
			if (EngBotConfig["moveLock"] == 0) then
				info["checked"] = 1;
			end
			UIDropDownMenu_AddButton(info, level);

			info = {
				["text"] = "Show Graphics",
				["value"] = nil,
				["func"] = function()
						if (EngBotConfig["show_top_graphics"] == 0) then
							EngBotConfig["show_top_graphics"] = 1;
						else
							EngBotConfig["show_top_graphics"] = 0;
						end
						EngBot_window_update_required = EngBot_MANDATORY;
						EngBot_UpdateWindow();
					end
				};
			if (EngBotConfig["show_top_graphics"] == 1) then
				info["checked"] = 1;
			end
			UIDropDownMenu_AddButton(info, level);

			info = { ["disabled"] = 1 };
			UIDropDownMenu_AddButton(info, level);

			info = {
				["text"] = "Reload",
				["value"] = nil,
				["func"] = function()
                        SendChatMessage(EngBot_GetReloadQuery(), "WHISPER", nil, GetUnitName("target"))
					end
				};
			UIDropDownMenu_AddButton(info, level);

			info = {
				["text"] = "Set button size";
				["value"] = { ["opt"]="set_button_size" },
				["hasArrow"] = 1
				};
			UIDropDownMenu_AddButton(info, level);

			info = { ["disabled"] = 1 };
			UIDropDownMenu_AddButton(info, level);


			info = {
				["text"] = "Background Color",
				["hasColorSwatch"] = 1,
				["hasOpacity"] = 1,
				["r"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_r"],
				["g"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_g"],
				["b"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_b"],
				["opacity"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_a"],
				["notClickable"] = 1,
				["value"] = { ["bar"]=EngBags_MAINWINDOWCOLORIDX, ["element"] = "background" },
				["swatchFunc"] = EngBot_SetNewColor,
				["cancelFunc"] = EngBot_SetNewColor,
				["opacityFunc"] = EngBot_SetNewColor
				};
			UIDropDownMenu_AddButton(info, level);
			info = {
				["text"] = "Border Color",
				["hasColorSwatch"] = 1,
				["hasOpacity"] = 1,
				["r"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_r"],
				["g"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_g"],
				["b"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_b"],
				["opacity"] = EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_a"],
				["notClickable"] = 1,
				["value"] = { ["bar"]=EngBags_MAINWINDOWCOLORIDX, ["element"] = "border" },
				["swatchFunc"] = EngBot_SetNewColor,
				["cancelFunc"] = EngBot_SetNewColor,
				["opacityFunc"] = EngBot_SetNewColor
				};
			UIDropDownMenu_AddButton(info, level);
			info = {
				["isTitle"] = 1,
				["text"] = "- UniRing EngBags v"..ENGBAGS_VERSION.." -",
				["notClickable"] = 1,
				["value"] = 0
				};
			UIDropDownMenu_AddButton(info, level);
		elseif (level == 2) then
			if (this.value ~= nil) then
				if (this.value["opt"] == "set_button_size") then
					for key,value in { 20,30,35,40,50 } do
						info = {
							["text"] = value.."x"..value;
							["value"] = value;
							["func"] = function()
									if ( (type(this.value) == "number") and (this.value > 19) ) then
										EngBotConfig["frameButtonSize"] = this.value;
										EngBot_CalcButtonSize(EngBotConfig["frameButtonSize"]);
										EngBot_window_update_required = EngBot_MANDATORY;
										EngBot_UpdateWindow();
									end
								end
							};
						if (EngBotConfig["frameButtonSize"] == value) then
							info["checked"] = 1;
						end
						UIDropDownMenu_AddButton(info, level);
					end
				end
			end
		end
	end
end


-- Main "right click menu"
function EngBot_frame_RightClickMenu_OnLoad()
	UIDropDownMenu_Initialize(this, EngBot_frame_RightClickMenu_populate, "MENU");
end


function EngBot_IncreaseColumns()
	if (EngBotConfig["maxColumns"] < EngBags_MAXCOLUMNS_MAX) then
		EngBotConfig["maxColumns"] = EngBotConfig["maxColumns"] + 1;
		EngBot_window_update_required = EngBot_MANDATORY;
		EngBot_UpdateWindow();
	end
end

function EngBot_DecreaseColumns()
	if (EngBotConfig["maxColumns"] > EngBags_MAXCOLUMNS_MIN) then
		EngBotConfig["maxColumns"] = EngBotConfig["maxColumns"] - 1;
		EngBot_window_update_required = EngBot_MANDATORY;
		EngBot_UpdateWindow();
	end
end

function EngBot_MoveAndSizeFrame(frameName, childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset, width, height)
        local frame = getglobal(frameName);

        if (frame) then
                frame:ClearAllPoints();
                frame:SetPoint(childAttachPoint, parentFrameName, parentAttachPoint, xoffset, yoffset);
                frame:SetWidth(width);
                frame:SetHeight(height);
                frame:Show();
        else
                message("Attempt to find frame '"..frameName.."' failed.");
        end
end


-- bar == current bar
-- currentbutton == next button to use
-- frame == name of background frame to be relative to
-- width/height == max number of buttons to place into frame
function EngBot_AssignButtonsToFrame(barnum, currentbutton, frame, width, height)
        local cur_x, cur_y, tmpframe;
	local position;
	local bagnum, slotnum;

        cur_x = 0;
        cur_y = 0;

        if (table.getn(EngBot_bar_positions[barnum]) > 0) then
                for position = 1, table.getn(EngBot_bar_positions[barnum]) do
			bagnum = EngBot_bar_positions[barnum][position]["bagnum"];
			slotnum = EngBot_bar_positions[barnum][position]["slotnum"];

                        EngBot_item_cache[bagnum][slotnum]["button_num"] = currentbutton;

                        EngBot_MoveAndSizeFrame("EngBot_frame_Item_"..currentbutton, "BOTTOMRIGHT",
                                frame, "BOTTOMRIGHT",
                                0-(
                                ((cur_x*EngBags_BUTTONFRAME_WIDTH )+EngBags_BUTTONFRAME_X_PADDING) + EngBotConfig["frameXSpace"]
                                ),
                                ((cur_y*EngBags_BUTTONFRAME_HEIGHT)+EngBags_BUTTONFRAME_Y_PADDING) + EngBotConfig["frameYSpace"],
                                EngBags_BUTTONFRAME_BUTTONWIDTH,
                                EngBags_BUTTONFRAME_BUTTONHEIGHT );

                        EngBot_buttons["EngBot_frame_Item_"..currentbutton] = { ["bar"]=barnum, ["position"]=position, ["bagnum"]=bagnum, ["slotnum"]=slotnum };
                        EngBot_UpdateButton( getglobal("EngBot_frame_Item_"..currentbutton), EngBot_item_cache[bagnum][slotnum] );

                        cur_x = cur_x + 1;
                        if (cur_x == width) then
                                cur_x = 0;
                                cur_y = cur_y + 1;
                        end

                        currentbutton = currentbutton + 1;
                end
        end

        if (EngBot_edit_mode == 1) then
                -- add extra button for targetting
                EngBot_MoveAndSizeFrame("EngBot_frame_SlotTarget_"..barnum, "BOTTOMRIGHT",
                        frame, "BOTTOMRIGHT",
                        0-(
                        (((width-1)*EngBags_BUTTONFRAME_WIDTH )+EngBags_BUTTONFRAME_X_PADDING) + EngBotConfig["frameXSpace"]
                        ),
                        (((height-1)*EngBags_BUTTONFRAME_HEIGHT)+EngBags_BUTTONFRAME_Y_PADDING) + EngBotConfig["frameYSpace"],
                        EngBags_BUTTONFRAME_BUTTONWIDTH,
                        EngBags_BUTTONFRAME_BUTTONHEIGHT );

                EngBot_MoveAndSizeFrame("EngBot_frame_SlotTarget_"..barnum.."_bkgr", "TOPLEFT",
                        "EngBot_frame_SlotTarget_"..barnum, "TOPLEFT",
                        0-EngBags_BUTTONFRAME_X_PADDING,
                        EngBags_BUTTONFRAME_Y_PADDING,
                        EngBags_BKGRFRAME_WIDTH,
                        EngBags_BKGRFRAME_HEIGHT );

                tmpframe = getglobal("EngBot_frame_SlotTarget_"..barnum.."_BigText");
                tmpframe:SetText( barnum );
                tmpframe:Show();
                tmpframe = getglobal("EngBot_frame_SlotTarget_"..barnum.."_bkgr");
                tmpframe:SetVertexColor( 1,0,0.25, 0.5 );
        end

        return currentbutton;
end

EngBot_WindowIsUpdating = 0;


function EngBot_UpdateWindow()
        local frame = getglobal("EngBot_frame");

        local currentbutton, barnum, slotnum;
        local barframe_one, barframe_two, barframe_three, tmpframe;
        local calc_dat, tmpcalc, cur_y;
        local available_width, width_in_between, mid_point;
        EngBags_PrintDEBUG("ei: UpdateWindow()  WindowIsUpdating="..EngBot_WindowIsUpdating );

        if (EngBot_WindowIsUpdating == 1) then
                return;
        end
        EngBot_WindowIsUpdating = 1;

        if ( EBLocal["_loaded"]==0 ) then
                EngBot_WindowIsUpdating = 0;
                return;
        end

	if ( not frame:IsVisible() ) then
		EngBot_WindowIsUpdating = 0;
	return;
	end

	if (EngBot_resort_required == EngBot_MANDATORY) then
		EngBot_Sort_item_cache();
	end

	if (EngBot_edit_mode == 1) then
		EngBot_WindowBottomPadding = EngBot_WINDOWBOTTOMPADDING_EDITMODE;
	else
		EngBot_WindowBottomPadding = EngBot_WINDOWBOTTOMPADDING_NORMALMODE;
	end

	if (EngBot_window_update_required > EngBot_NOTNEEDED) then

		currentbutton = 1;
		cur_y = EngBotConfig["frameYSpace"] + EngBot_WindowBottomPadding;
		for barnum = 1, EngBags_MAX_BARS, 3 do
			barframe_one = getglobal("EngBot_frame_bar_"..barnum);
			barframe_two = getglobal("EngBot_frame_bar_"..(barnum+1));
			barframe_three = getglobal("EngBot_frame_bar_"..(barnum+2));

			calc_dat = {};
			calc_dat = {
				["first"] = table.getn(EngBot_bar_positions[barnum]),
				["second"] = table.getn(EngBot_bar_positions[barnum+1]),
				["third"] = table.getn(EngBot_bar_positions[barnum+2])
				};
			if (EngBot_edit_mode == 1) then
				-- add an extra slot if we're in edit mode
				calc_dat["first"] = calc_dat["first"] + 1;
				calc_dat["second"] = calc_dat["second"] + 1;
				calc_dat["third"] = calc_dat["third"] + 1;
			else
				-- we're not in edit mode, make sure the SlotTarget button and texture is hidden
				for vbarnum = 0, 2 do
				tmpframe = getglobal("EngBot_frame_SlotTarget_"..(barnum+vbarnum));
				tmpframe:Hide();
				tmpframe = getglobal("EngBot_frame_SlotTarget_"..(barnum+vbarnum).."_bkgr");
				tmpframe:Hide();
				end
			end
			--calc_dat["total_in_row"] = calc_dat["first"] + calc_dat["second"] + calc_dat["third"];

    			for index,element in ipairs(EngBags_Bars) do
				calc_dat[element.."_heighttable"] = {};
				if calc_dat[element] > 0 then
					for tmpcalc = 1, calc_dat[element] do
						calc_dat[element.."_heighttable"][tmpcalc] = math.ceil( calc_dat[element] / tmpcalc );
					end
				end
			end

			calc_dat["height"] = 0;
			repeat
				calc_dat["height"] = calc_dat["height"] + 1;
				tmpcalc = 0;
				for index,element in ipairs(EngBags_Bars) do
					if (calc_dat[element] > 0) then
						if (calc_dat[element.."_heighttable"][calc_dat["height"]]) then
							tmpcalc = tmpcalc + calc_dat[element.."_heighttable"][calc_dat["height"]];
						else
							tmpcalc = tmpcalc + 1;
						end
					end
				end

			until tmpcalc <= EngBotConfig["maxColumns"];

			if tmpcalc == 0 then
				calc_dat["height"] = 0;
			else

				-- at calc_dat["height"], everything fits
				for index,element in ipairs(EngBags_Bars) do
				if calc_dat[element] > 0 then
					if (calc_dat[element.."_heighttable"][calc_dat["height"]]) then
						calc_dat[element.."_width"] = calc_dat[element.."_heighttable"][calc_dat["height"]];
					else
						calc_dat[element.."_width"] = 1;
					end
				else
					calc_dat[element.."_width"] = 0;
				end
				end

			end

			--- now we know the size and height of all 3 bars for this line

			if (calc_dat["height"] == 0) then
				barframe_one:Hide();
				barframe_two:Hide();
				barframe_three:Hide();
			else
				available_width = (EngBotConfig["maxColumns"]*EngBags_BUTTONFRAME_WIDTH) + (10*EngBotConfig["frameXSpace"]);

				------------------------------------------------------------------------------------------
				--------- FIRST BAR
				if (calc_dat["first_width"] > 0) then
				EngBot_MoveAndSizeFrame("EngBot_frame_bar_"..barnum, "BOTTOMRIGHT",
					"EngBot_frame", "BOTTOMRIGHT",
					0-EngBotConfig["frameXSpace"],
					cur_y,
					(calc_dat["first_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"]),
					(calc_dat["height"]*EngBags_BUTTONFRAME_HEIGHT)+(2*EngBotConfig["frameYSpace"]) );
				barframe_one:SetBackdropColor(
					EngBotConfig["bar_colors_"..barnum.."_background_r"],
					EngBotConfig["bar_colors_"..barnum.."_background_g"],
					EngBotConfig["bar_colors_"..barnum.."_background_b"],
					EngBotConfig["bar_colors_"..barnum.."_background_a"] );
				barframe_one:SetBackdropBorderColor(
					EngBotConfig["bar_colors_"..barnum.."_border_r"],
					EngBotConfig["bar_colors_"..barnum.."_border_g"],
					EngBotConfig["bar_colors_"..barnum.."_border_b"],
					EngBotConfig["bar_colors_"..barnum.."_border_a"] );
				else
					barframe_one:Hide();
				end
				------------------------------------------------------------------------------------------
				--------- SECOND BAR
				if (calc_dat["second_width"] > 0) then
					width_in_between = available_width - (
						(EngBotConfig["frameXSpace"] * 4) +       -- border on both sides + borders between frames
						((calc_dat["first_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"])) +      -- bar 1 size
						((calc_dat["third_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"]))        -- bar 3 size
						);
					mid_point = (width_in_between/2) +
						((calc_dat["first_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"])) +
						(EngBotConfig["frameXSpace"] * 2);


					EngBot_MoveAndSizeFrame("EngBot_frame_bar_"..(barnum+1), "BOTTOMRIGHT",
						"EngBot_frame", "BOTTOMRIGHT",
						0-( mid_point - (((calc_dat["second_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"]))/2) ),
						cur_y,
						(calc_dat["second_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"]),
						(calc_dat["height"]*EngBags_BUTTONFRAME_HEIGHT)+(2*EngBotConfig["frameYSpace"]) );
					barframe_two:SetBackdropColor(
						EngBotConfig["bar_colors_"..(barnum+1).."_background_r"],
						EngBotConfig["bar_colors_"..(barnum+1).."_background_g"],
						EngBotConfig["bar_colors_"..(barnum+1).."_background_b"],
						EngBotConfig["bar_colors_"..(barnum+1).."_background_a"] );
					barframe_two:SetBackdropBorderColor(
						EngBotConfig["bar_colors_"..(barnum+1).."_border_r"],
						EngBotConfig["bar_colors_"..(barnum+1).."_border_g"],
						EngBotConfig["bar_colors_"..(barnum+1).."_border_b"],
						EngBotConfig["bar_colors_"..(barnum+1).."_border_a"] );
				else
					barframe_two:Hide();
				end

				------------------------------------------------------------------------------------------
				--------- THIRD BAR
				if (calc_dat["third_width"] > 0) then
				EngBot_MoveAndSizeFrame("EngBot_frame_bar_"..(barnum+2), "BOTTOMRIGHT",
					"EngBot_frame", "BOTTOMRIGHT",
					(0-available_width) +(calc_dat["third_width"]*EngBags_BUTTONFRAME_WIDTH)+(3*EngBotConfig["frameXSpace"]),
					cur_y,
					(calc_dat["third_width"]*EngBags_BUTTONFRAME_WIDTH)+(2*EngBotConfig["frameXSpace"]),
					(calc_dat["height"]*EngBags_BUTTONFRAME_HEIGHT)+(2*EngBotConfig["frameYSpace"]) );
				barframe_three:SetBackdropColor(
					EngBotConfig["bar_colors_"..(barnum+2).."_background_r"],
					EngBotConfig["bar_colors_"..(barnum+2).."_background_g"],
					EngBotConfig["bar_colors_"..(barnum+2).."_background_b"],
					EngBotConfig["bar_colors_"..(barnum+2).."_background_a"] );
				barframe_three:SetBackdropBorderColor(
					EngBotConfig["bar_colors_"..(barnum+2).."_border_r"],
					EngBotConfig["bar_colors_"..(barnum+2).."_border_g"],
					EngBotConfig["bar_colors_"..(barnum+2).."_border_b"],
					EngBotConfig["bar_colors_"..(barnum+2).."_border_a"] );
				else
					barframe_three:Hide();
				end
				-----
				currentbutton = EngBot_AssignButtonsToFrame(barnum, currentbutton,
					"EngBot_frame_bar_"..(barnum),
					calc_dat["first_width"], calc_dat["height"] );
				currentbutton = EngBot_AssignButtonsToFrame(barnum+1, currentbutton,
					"EngBot_frame_bar_"..(barnum+1),
					calc_dat["second_width"], calc_dat["height"] );
				currentbutton = EngBot_AssignButtonsToFrame(barnum+2, currentbutton,
					"EngBot_frame_bar_"..(barnum+2),
					calc_dat["third_width"], calc_dat["height"] );

				cur_y = cur_y + (calc_dat["height"]*EngBags_BUTTONFRAME_HEIGHT)+(3*EngBotConfig["frameYSpace"]);
			end
		end

		-- hide unused buttons
		if (currentbutton <= EngBot_MAXBUTTONS) then
			for currentbutton = currentbutton, EngBot_MAXBUTTONS do
				tmpframe = getglobal("EngBot_frame_Item_"..(currentbutton));
				tmpframe:Hide();
			end
		end

		local new_width = (EngBotConfig["maxColumns"]*EngBags_BUTTONFRAME_WIDTH) + (10*EngBotConfig["frameXSpace"]);
		local new_height;

		if (EngBotConfig["show_top_graphics"] == 1) then
			new_height = cur_y + EngBot_TOP_PADWINDOW;
		else
			new_height = cur_y + 25;
		end

		frame:SetWidth( new_width );
		frame:SetHeight( new_height );

		frame:ClearAllPoints();
		frame:SetPoint(EngBotConfig["frameYRelativeTo"]..EngBotConfig["frameXRelativeTo"],
			"UIParent", "BOTTOMLEFT",
			EngBotConfig["frame"..EngBotConfig["frameXRelativeTo"]] / frame:GetScale(),
			EngBotConfig["frame"..EngBotConfig["frameYRelativeTo"]] / frame:GetScale());

		frame:SetBackdropColor(
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_r"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_g"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_b"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_background_a"] );
		frame:SetBackdropBorderColor(
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_r"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_g"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_b"],
			EngBotConfig["bar_colors_"..EngBags_MAINWINDOWCOLORIDX.."_border_a"] );

        EngBags_UserDropdown:Hide();
        EngBot_SlotCostFrame:Hide();
        EngBot_PurchaseButton:Hide();


		if (EngBot_edit_mode == 1) then
			EngBot_Button_ColumnsAdd:SetText(EBLocal["EngBot_Button_ColumnsAdd_buttontitle"]);
			EngBot_Button_ColumnsAdd:Show();
			EngBot_Button_ColumnsDel:SetText(EBLocal["EngBot_Button_ColumnsDel_buttontitle"]);
			EngBot_Button_ColumnsDel:Show();
		else
			EngBot_Button_ColumnsAdd:Hide();
			EngBot_Button_ColumnsDel:Hide();
		end

		if (EngBotConfig["show_top_graphics"] == 1) then
			--EngBot_Button_Close:Show();
			--EngBot_Button_MoveLockToggle:Show();
			EngBot_Button_ChangeEditMode:Show();
			EngBot_Button_HighlightToggle:Hide();

			EngBot_framePortrait:Hide();
			EngBot_frameTextureTopLeft:Hide();
			EngBot_frameTextureTopCenter:Hide();
			EngBot_frameTextureTopRight:Hide();
			EngBot_frameTextureLeft:Hide();
--			EngBot_frameTextureCenter:Hide();
			EngBot_frameTextureRight:Hide();
			EngBot_frameTextureBottomLeft:Hide();
			EngBot_frameTextureBottomCenter:Hide();
			EngBot_frameTextureBottomRight:Hide();
		else
			-- hide all the top graphics
			--EngBot_Button_Close:Hide();
			--EngBot_Button_MoveLockToggle:Hide();
			EngBot_Button_ChangeEditMode:Hide();
			EngBot_Button_HighlightToggle:Hide();

			EngBot_framePortrait:Hide();
			EngBot_frameTextureTopLeft:Hide();
			EngBot_frameTextureTopCenter:Hide();
			EngBot_frameTextureTopRight:Hide();
			EngBot_frameTextureLeft:Hide();
--			EngBot_frameTextureCenter:Hide();
			EngBot_frameTextureRight:Hide();
			EngBot_frameTextureBottomLeft:Hide();
			EngBot_frameTextureBottomCenter:Hide();
			EngBot_frameTextureBottomRight:Hide();
			-- Reposition the dropdown list
			-- EngBags_UserDropdown:SetPoint("TOPRIGHT", 12, 25);
		end
	end

	EngBot_window_update_required = EngBot_NOTNEEDED;

        EngBot_WindowIsUpdating = 0;
end

function wait(delay, func, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("OnUpdate",function ()
      local elapse = 0.1
      local count = tablelength(waitTable);
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9}});
  return true;
end
