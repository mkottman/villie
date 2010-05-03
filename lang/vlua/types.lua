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
		Function = { color = "plum", icon = "lang/vlua/icons/function.png" };
		Funcdef = { color = "plum", icon = "lang/vlua/icons/function.png",
			proto = {'Iname', 'Iarg1'};
		};

		If = { color = "skyblue", poly = QPolygonF.new_local()
				:IN(QPointF.new_local(-WW, 0))
				:IN(QPointF.new_local(0, -HH))
				:IN(QPointF.new_local(WW, 0))
				:IN(QPointF.new_local(0, HH));
			proto = {'Icondition', 'Bbody', 'Belse'};
		};
		Fornum = { color = "yellow", icon = "lang/vlua/icons/loop.png", poly = QPolygonF.new_local()
				:IN(QPointF.new_local(-WW+FOR_EDGE, -HH))
				:IN(QPointF.new_local( WW-FOR_EDGE, -HH))
				:IN(QPointF.new_local( WW         , -HH+FOR_EDGE))
				:IN(QPointF.new_local( WW         , HH-FOR_EDGE))
				:IN(QPointF.new_local( WW-FOR_EDGE, HH))
				:IN(QPointF.new_local(-WW+FOR_EDGE, HH))
				:IN(QPointF.new_local(-WW         , HH-FOR_EDGE))
				:IN(QPointF.new_local(-WW         , -HH+FOR_EDGE));
			proto = {'Ivariable', 'Ifrom', 'Ito', 'Bbody'};
		};
		Forin = { color = "orange", icon = "lang/vlua/icons/loop.png",
			proto = {'Ivariable', 'Iiterator', 'Bbody'};
		};
		While = { color = "brown", icon = "lang/vlua/icons/loop.png",
			proto = {'Icondition', 'Bbody'};
		};
		Repeat = { color = "brown", icon = "lang/vlua/icons/loop.png", iconRight = true,
			proto = {'Icondition', 'Bbody'};
		};

		Set = { color = "white", icon = "lang/vlua/icons/assign.gif",
			proto = {'Ivalue', 'Otarget'};
		};
		Local = { color = "wheat", icon = "lang/vlua/icons/local.png",
			proto = {'Ivalue', 'Odefines'};
		};

		Return = { color = "lightgray", icon = "lang/vlua/icons/return.png",
			proto = {'Ireturns'};
		};
		Break = { color = "gray", icon = "lang/vlua/icons/break.png" };
		
		Call = { color = "lightblue", poly = QPolygonF.new_local()
				:IN(QPointF.new_local(-WW+20, -HH))
				:IN(QPointF.new_local(WW, -HH))
				:IN(QPointF.new_local(WW-20, HH))
				:IN(QPointF.new_local(-WW, HH));
			proto = {'Ifunction', 'Iarg1'};
		};
		Invoke = { color = "blue", poly = QPolygonF.new_local()
				:IN(QPointF.new_local(-WW+20, -HH))
				:IN(QPointF.new_local(WW, -HH))
				:IN(QPointF.new_local(WW-20, HH))
				:IN(QPointF.new_local(-WW, HH));
			proto = {'Iobject', 'Imethod', 'Iarg1'};
		};

		Block = { color = "white" };
		Locals = { color = "cyan" };
		Ref = { color = "cyan" };
		Unknown = { color = "red" }; -- placeholder
	};
}
