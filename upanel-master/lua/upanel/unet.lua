upanel.net = {}

if SERVER then
	util.AddNetworkString("upanel_net_fail")
end

local rMessage = {
	angle = net.ReadAngle,
	bit = net.ReadBit,
	bool = net.ReadBool,
	color = net.ReadColor,
	data = net.ReadData,
	double = net.ReadDouble,
	entity = net.ReadEntity,
	float = net.ReadFloat,
	header = net.ReadHeader,
	int = net.ReadInt,
	matrix = net.ReadMatrix,
	normal = net.ReadNormal,
	string = net.ReadString,
	table = net.ReadTable,
	type = net.ReadType,
	uint = net.ReadUInt,
	vector = net.ReadVector
}

local RECEIVED_MESSAGE = {}
RECEIVED_MESSAGE._addMethod = function(self, name, func) self[name] = function(self, ...) return func(...) end end
for k, v in pairs(rMessage) do
	RECEIVED_MESSAGE:_addMethod(k, v)
end
RECEIVED_MESSAGE.__index = RECEIVED_MESSAGE

local nMessage = {
	send = (CLIENT and net.SendToServer or net.Send),
	sendOmit = net.SendOmit, -- SV
	sendPAS = net.SendPAS, -- SV
	sendPVS = net.SendPVS, -- SV
	broadcast = net.Broadcast, -- SV

	getSize = net.BytesWritten,

	angle = net.WriteAngle,
	bit = net.WriteBit,
	bool = net.WriteBool,
	color = net.WriteColor,
	data = net.WriteData,
	double = net.WriteDouble,
	entity = net.WriteEntity,
	float = net.WriteFloat,
	int = net.WriteInt,
	matrix = net.WriteMatrix,
	normal = net.WriteNormal,
	string = net.WriteString,
	table = net.WriteTable,
	type = net.WriteType,
	uint = net.WriteUInt,
	vector = net.WriteVector
}

local MESSAGE = {}
MESSAGE._addMethod = function(self, name, func) self[name] = function(self, ...) func(...) return self end end
for k, v in pairs(nMessage) do
	MESSAGE:_addMethod(k, v)
end
MESSAGE.__index = MESSAGE

upanel.net.msg = function(name)
	local msg = {}
	setmetatable(msg, MESSAGE)
	msg.name = name

	net.Start(name)

	return msg
end

upanel.net.receive = function(name, callback)
	net.Receive(name, function(len, ply)
		local msg = {}
		setmetatable(msg, RECEIVED_MESSAGE)
		msg.length = len

		if SERVER then
			msg.name = name
			msg.sender = ply
			msg.getSize = function(self) return self.length end
			msg.getPlayer = function(self) return self.sender end
			msg.isPermitted = function(self, perm)
				if !IsValid(self.sender) then return false end

				return upanel.permissions.check(self.sender, perm)
			end
			msg.fail = function(self, error) 
				if !IsValid(self.sender) then return end

				upanel.net.msg("upanel_net_fail"):string(name):string(error):send(self.sender)
			end
			msg.unpack = function(self, ...)
				local temp = {}
				for _, t in pairs({...}) do
					local value = self[t]()
					if type(value):lower() != t then return false end
					table.insert(temp, value)
				end
				return temp
			end
			msg.reply = function(self, msg_name) return upanel.net.msg(msg_name or self.name) end
		end

		callback(msg, ply)
	end)
end

if CLIENT then
	upanel.net.receive("upanel_net_fail", function(msg)
		chat.AddText(Color(255, 0, 0), "uPanel: ", color_white, "Net message '" .. msg:string() .. "' has failed.")
		chat.AddText(Color(255, 0, 0), "uPanel: ", Color(255, 150, 0), msg:string())
		surface.PlaySound("common/warning.wav")
	end)
end