local w, h = guiGetScreenSize();
local resW, resH = 1366, 768;
local sW, sH = ( w / resW ), ( h / resH );
local current_alert_data = {};
---Настройки
local font_alert = dxCreateFont ( 'RobotoCondensed-Light.ttf', 11 * sH ); --Шрифт
local size_text_alert = 1; --Размер шрифта
local w_alert = 300 * sW; --Максимальная ширина уведомления
local offset_x = 16 * sW; --Отступ от края экрана по оси X
local position = { w - ( w_alert + offset_x ), 170 * sH }; --Стартовые позиции X, Y на экране
local alpha = 100; --Отображаемая альфа
local max_alerts_on_screen = 5; --Максимум уведомлений на экране
local timeout_string = 2500; --Таймаут показа для одной строки (например, уведомление с одной строкой будет отображаться 2500мс, а уведомление с 3 строками будет отображаться 7500мс)
local offset_settings = { 'left', 'center' }; --Положение текста в уведомлении
local h_text = dxGetFontHeight ( size_text_alert, font_alert ); --Высота шрифта
local offset_text = 10 * sH; --Отступы по краям
local offset_alert = 5 * sH; --Расстояние между уведомлениями
local start_showing_speed = 6; --Насколько быстро будет появляться уведомление (рекомендуемые значения от 1 до 255)
local stop_showing_speed = 2; --Насколько быстро будет исчезать уведомление (рекомендуемые значения от 1 до 255)

function render()
	if #current_alert_data > 0 then
	local pos_y = position[2];
		for i = 1, #current_alert_data do
			if current_alert_data[i].h then
				if i > 1 then
				pos_y = pos_y + offset_alert + current_alert_data[i - 1].h;
					if current_alert_data[i - 1].settings then
					pos_y = pos_y + ( 23 * sH );
					end
				end
				
				local pos_x = w - ( current_alert_data[i].w_t + ( offset_x * sW ) );
				dxDrawRectangle ( pos_x, pos_y, current_alert_data[i].w_t, current_alert_data[i].h, tocolor ( 0, 0, 0, current_alert_data[i].a ), false );
				
				if current_alert_data[i].text then
				dxDrawText ( tostring ( current_alert_data[i].text ), pos_x + offset_text, pos_y + offset_text, pos_x + ( current_alert_data[i].w_t - ( offset_text ) ), pos_y + ( current_alert_data[i].h - ( offset_text ) ), tocolor ( 255, 255, 255, ( current_alert_data[i].a ) + ( 255 - alpha ) ), size_text_alert, font_alert, offset_settings[1], offset_settings[2], false, false, false, true, false );
				end
				
				if current_alert_data[i].settings then
				local percent = math.floor ( ( current_alert_data[i].settings[2] / 100 ) * current_alert_data[i].settings[1] );
				local t_offset = dxGetTextWidth ( tostring ( percent )..'%', size_text_alert, font_alert, true ) + ( 5 * sW );
				dxDrawRectangle ( pos_x, ( pos_y + current_alert_data[i].h ), current_alert_data[i].w_t, 23 * sH, tocolor ( 0, 0, 0, current_alert_data[i].a ), false );
				local widh = ( current_alert_data[i].w_t - ( offset_text * 2 ) ) - t_offset;
				
				dxDrawText ( tostring ( percent )..'%', pos_x + offset_text, ( pos_y + current_alert_data[i].h ), pos_x + ( current_alert_data[i].w_t - ( offset_text ) ), ( pos_y + current_alert_data[i].h ) + ( 18 * sH ), tocolor ( 255, 255, 255, ( current_alert_data[i].a ) + ( 255 - alpha ) ), size_text_alert, font_alert, offset_settings[1], offset_settings[2], false, false, false, true, false );
				dxDrawRectangle ( pos_x + offset_text + t_offset, ( pos_y + current_alert_data[i].h ) + ( 5 * sW ), widh, 8 * sH, tocolor ( 100, 100, 100, current_alert_data[i].a ), false );
				dxDrawRectangle ( pos_x + offset_text + t_offset, ( pos_y + current_alert_data[i].h ) + ( 5 * sW ), ( widh / current_alert_data[i].settings[2] ) * current_alert_data[i].settings[1], 8 * sH, tocolor ( 255, 255, 255, current_alert_data[i].a ), false );
				end
			end
			
			local tick = getTickCount();
			
			if tick - current_alert_data[i].tick <= current_alert_data[i].showtime then
				if current_alert_data[i].a < alpha then
					if tick - current_alert_data[i].alphatick >= current_alert_data[i].timeoutalpha then
					current_alert_data[i].a = current_alert_data[i].a + start_showing_speed;
					current_alert_data[i].alphatick = getTickCount();
						if current_alert_data[i].a > alpha then
						current_alert_data[i].a = alpha;
						end
					end
				end
			else
				if current_alert_data[i].a > 0 then
					if tick - current_alert_data[i].alphatick >= current_alert_data[i].timeoutalpha then
					current_alert_data[i].a = current_alert_data[i].a - stop_showing_speed;
					current_alert_data[i].alphatick = getTickCount();
						if current_alert_data[i].a < 0 then
						current_alert_data[i].a = 0;
						end
					end
				else
				return destroyAlert ( i );
				end
			end
		end
	end
end

function destroyAlert ( id )
table.remove ( current_alert_data, id );
	if #current_alert_data == 0 then
		if isEventHandlerAdded ( 'onClientRender', getRootElement(), render ) then
		removeEventHandler ( 'onClientRender', getRootElement(), render );
		current_alert_data = {};
		end
	end
end

function convertString ( text, w_t )
local temp = split ( tostring ( text ), ' ' );
	if #temp > 0 then
	local out_string = '';
	local strings = 0;
	local temp_strings = '';
		for i = 1, #temp do
		local w_text = dxGetTextWidth ( temp_strings..' '..temp[i], size_text_alert, font_alert, true );
			if utf8.find ( temp[i], '\n\n' ) then
			strings = strings + 2;
			elseif utf8.find ( temp[i], '\n' ) then
			strings = strings + 1;
			end
			
			if w_text < w_t - ( offset_text * 2 ) then
				if temp_strings:gsub ( ' ', '' ) ~= '' then
				temp_strings = temp_strings..' ';
				end
				
				temp_strings = temp_strings..temp[i];
			else
			out_string = out_string..temp_strings..'\n';
			temp_strings = temp[i];
			strings = strings + 1;
			end
		end
		
		if temp_strings:gsub ( ' ', '' ) ~= '' then
		out_string = out_string..temp_strings;
		strings = strings + 1;
		end
		
		return out_string, ( ( h_text * strings ) + ( offset_text ) ), strings * timeout_string;
	end
	return text, h_text + ( offset_text ), timeout_string;
end

function createAlert ( data, type_alert, settings )
if type_alert == 'string' then
if #current_alert_data >= max_alerts_on_screen then
table.remove ( current_alert_data, 1 );
end

local id = #current_alert_data + 1;

local w_t = w_alert;

if dxGetTextWidth ( tostring ( data ), size_text_alert, font_alert, true ) < w_alert then
w_t = dxGetTextWidth ( tostring ( data ), size_text_alert, font_alert, true ) + ( offset_text * 2 );
end

local t_text, t_h, t_showtime = convertString ( tostring ( data ), w_t );
--playSoundFrontEnd ( 11 ); Звуковое сопровождение

current_alert_data[id] = {
text = t_text;
h = t_h;
a = 0;
showtime = t_showtime;
tick = getTickCount();
alphatick = getTickCount();
timeoutalpha = 1;
settings = settings;
w_t = w_t};
t_text = string.gsub(t_text, "#%x%x%x%x%x%x", "")
outputConsole("Уведомление: "..t_text.."")
if not isEventHandlerAdded ( 'onClientRender', getRootElement(), render, true, 'low-9999' ) then
addEventHandler ( 'onClientRender', getRootElement(), render, true, 'low-9999' );
end
end
end

function alert ( data, settings )
	if data then
		if type ( data ) == 'string' then
		createAlert ( data, 'string', settings );
		end
	end
end
addEvent ( 'alert', true );
addEventHandler ( 'alert', getRootElement(), alert );

function isEventHandlerAdded ( sEventName, pElementAttachedTo, func )
	if type ( sEventName ) == 'string' and isElement ( pElementAttachedTo ) and type ( func ) == 'function' then
	local aAttachedFunctions = getEventHandlers ( sEventName, pElementAttachedTo );
		if type ( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs ( aAttachedFunctions ) do
				if v == func then
				return true;
				end
			end
		end
	end
	return false;
end

-----====================================================
--Тестовые функции, для проверки скрипта-----------------
-----====================================================

local allowed = { { 48, 57 }, { 65, 90 }, { 97, 122 } };

function RGBToHex ( red, green, blue )
	if red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 then
	return nil;
	end
	return string.format ( '#%.2X%.2X%.2X', red, green, blue );
end

function generateString ( len )
    if tonumber ( len ) then
    math.randomseed ( getTickCount () );
    local str = '';
        for i = 1, len do
        local charlist = allowed[math.random ( 1, 3 )];
		local space = math.random ( 1, 5 );
        str = str .. string.char ( math.random ( charlist[1], charlist[2] ) );
			if space == 1 then
			local hex = RGBToHex ( math.random ( 0, 255 ), math.random ( 0, 255 ), math.random ( 0, 255 ) );
			str = str..' '..hex;
			end
        end
        return str;
    end
    return false;
end

--[[function randomAlert()
	alert ( generateString ( math.random ( 5, 126 ) ) );
	setTimer (
		function()
		randomAlert();
		end, math.random ( 1000, 5000 ), 1
	);
end

randomAlert();]]