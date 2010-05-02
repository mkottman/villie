local HEIGHT = 30
local WIDTH = 240
local WW = WIDTH/2
local HH = HEIGHT/2
local CALL_EDGE = 20
local FOR_EDGE = 10

return {
	nodes = {
		Expression = { };
		Info = { };
		Exp = { };
		Stat = { };
	};
	edges = {
		Function = { color = "blue", icon = "lang/vlua/icons/function.png" };
		Funcdef = { color = "plum", icon = "lang/vlua/icons/function.png" };

		If = { color = "skyblue", poly = QPolygonF.new_local()
			:IN(QPointF.new_local(-WW, 0))
			:IN(QPointF.new_local(0, -HH))
			:IN(QPointF.new_local(WW, 0))
			:IN(QPointF.new_local(0, HH));
		};
		Fornum = { color = "yellow", icon = "lang/vlua/icons/loop.png", poly = QPolygonF.new_local()
			:IN(QPointF.new_local(-WW+FOR_EDGE, -HH))
			:IN(QPointF.new_local( WW-FOR_EDGE, -HH))
			:IN(QPointF.new_local( WW         , -HH+FOR_EDGE))
			:IN(QPointF.new_local( WW         , HH-FOR_EDGE))
			:IN(QPointF.new_local( WW-FOR_EDGE, HH))
			:IN(QPointF.new_local(-WW+FOR_EDGE, HH))
			:IN(QPointF.new_local(-WW         , HH-FOR_EDGE))
			:IN(QPointF.new_local(-WW         , -HH+FOR_EDGE))
		};
		Forin = { color = "orange", icon = "lang/vlua/icons/loop.png" };
		While = { color = "brown", icon = "lang/vlua/icons/loop.png" };
		Repeat = { color = "brown", icon = "lang/vlua/icons/loop.png", iconRight = true };

		Set = { color = "white", icon = "lang/vlua/icons/assign.gif" };
		Local = { color = "wheat", icon = "lang/vlua/icons/local.png" };

		Return = { color = "lightgray", icon = "lang/vlua/icons/return.png" };
		Break = { color = "gray", icon = "lang/vlua/icons/break.png" };
		
		Call = { color = "lightblue", poly = QPolygonF.new_local()
			:IN(QPointF.new_local(-WW+20, -HH))
			:IN(QPointF.new_local(WW, -HH))
			:IN(QPointF.new_local(WW-20, HH))
			:IN(QPointF.new_local(-WW, HH));
		};
		Invoke = { color = "blue", poly = QPolygonF.new_local()
			:IN(QPointF.new_local(-WW+20, -HH))
			:IN(QPointF.new_local(WW, -HH))
			:IN(QPointF.new_local(WW-20, HH))
			:IN(QPointF.new_local(-WW, HH));
		};

		Block = { color = "white" };		
		Locals = { color = "cyan" };
		Ref = { color = "cyan" };
		Unknown = { color = "red" }; -- placeholder
	};
}
