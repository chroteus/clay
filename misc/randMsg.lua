local RandMsg = class("RandMsg")

function RandMsg:initialize(messages)
	self.messages = messages
end

function RandMsg:__call()
	local rnum = math.random(#self.messages)
	return self.messages[rnum]
end

------------------------------------------------------------------------

local msg = {}

msg.foe = {}
msg.foe.enter = RandMsg{
	"Freedom ain't free. You, "..Player.country..", is the sacrifice.",
	"What do you want, "..Player.country.."?!",
	"Stop stealing my clay, "..Player.country.."!",
	"Who the hell are you? Oh right, you're "..Player.country.."!",
	"Bloody hell, it's you again.",
}

msg.foe.denyPeace = RandMsg{
	"Peace? Ha! No way.",
	"No.",
	"Never!",
}


return msg
