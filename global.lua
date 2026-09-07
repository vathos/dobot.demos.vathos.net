function splitString(string, separator)
	local tab = {};
		string.gsub(string, "[^" .. separator .. "]+", function(w)
			table.insert(tab, w);
		end);
		return tab;
end

function load_configuration(product, workflow, host, port)
	local resultOpen, socket = TCPCreate(false, host, port);
	if resultOpen ~= 0 then
		print("Create TCP Client failed, code:", resultOpen);
	end;
	resultOpen = TCPStart(socket, 0);
	if resultOpen ~= 0 then
		print("Connect TCP Server failed, code:", resultOpen);
		return
	end;
	local resultWrite = TCPWrite(socket, "load_configuration;" .. product .. ";" .. workflow);
	if resultWrite ~= 0 then
		print("Writing to socket failed, code:", resultOpen);
		return
	end;
	local resultRead, response = TCPRead(socket, 0, "string");
	if resultRead ~= 0 then
		print("Reading response failed, code:", resultOpen);
		return
	end;
	TCPDestroy(socket);
	local responseParsed = splitString(response, ";");
	if tonumber(responseParsed[1]) == (-1) then
		print("Load configuration failed, message:", responseParsed[2]);
	end;
end;

function save_image(sessionId, host, port)
	local currentPose = GetPose();
	-- make sure locations are sent in meters!
	local x = 0.0001 * currentPose.pose[1];
	local y = 0.0001 * currentPose.pose[2];
	local z = 0.0001 * currentPose.pose[3];
	local rx = currentPose.pose[4];
	local ry = currentPose.pose[5];
	local rz = currentPose.pose[6];
	local requestBody = "save_image;depth;-1;" .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(z) .. "," .. tostring(rx) .. "," .. tostring(ry) .. "," .. tostring(rz) .. ";xyz;1;" .. sessionId;
	local resultOpen, socket = TCPCreate(false, host, port);
	if resultOpen ~= 0 then
		print("Create TCP Client failed, code:", resultOpen);
	end;
	resultOpen = TCPStart(socket, 0);
	if resultOpen ~= 0 then
		print("Connect TCP Server failed, code:", resultOpen);
		return
	end;
	local resultWrite = TCPWrite(socket, requestBody);
	if resultWrite ~= 0 then
		print("Writing to socket failed, code:", resultOpen);
		return
	end;
	local resultRead, response = TCPRead(socket, 0, "string");
	if resultRead ~= 0 then
		print("Reading response failed, code:", resultOpen);
		return
	end;
	TCPDestroy(socket);
	local responseParsed = splitString(response, ";");
	if tonumber(responseParsed[1]) == (-1) then
		print("Saving image failed, message:", responseParsed[2]);
	end;
end;

function trigger(workflow, host, port)
	local resultOpen, socket = TCPCreate(false, host, port);
	if resultOpen ~= 0 then
		print("Create TCP Client failed, code:", resultOpen);
	end;
	resultOpen = TCPStart(socket, 0);
	if resultOpen ~= 0 then
		print("Connect TCP Server failed, code:", resultOpen);
		return
	end;
	local resultWrite = TCPWrite(socket, "trigger;" .. workflow .. ";1;depth");
	if resultWrite ~= 0 then
		print("Writing to socket failed, code:", resultOpen);
		return
	end;
	local resultRead, response = TCPRead(socket, 0, "string");
	if resultRead ~= 0 then
		print("Reading response failed, code:", resultOpen);
		return
	end;
	TCPDestroy(socket);
	local responseParsed = splitString(response, ";");
	if tonumber(responseParsed[1]) == (-1) then
		print("Trigger failed, response:", responseParsed[2]);
	end;
end;

function get_pose(workflow, timeout, host, port)
	local resultOpen, socket = TCPCreate(false, host, port);
	if resultOpen ~= 0 then
		print("Create TCP Client failed, code:", resultOpen);
	end;
	resultOpen = TCPStart(socket, 0);
	if resultOpen ~= 0 then
		print("Connect TCP Server failed, code:", resultOpen);
		return
	end;
	local resultWrite = TCPWrite(socket, "get_pose;" .. workflow .. ";xyz;1;" .. timeout);
	if resultWrite ~= 0 then
		print("Writing to socket failed, code:", resultOpen);
		return
	end;
	local resultRead, response = TCPRead(socket, 0, "string");
	if resultRead ~= 0 then
		print("Reading response failed, code:", resultOpen);
		return
	end;
	TCPDestroy(socket);
	local responseParsed = splitString(response, ";");
	if tonumber(responseParsed[1]) == (-1) then
		print("Get pose failed, message:", responseParsed[2]);
	end;
	local poseData = splitString(responseParsed[2], ",");
	local pose = {};
	for i = 1, 6 do
		pose[i] = tonumber(poseData[i]);
	end;
	-- make sure to convert back to mm
	pose[1] = 1000 * pose[1];
	pose[2] = 1000 * pose[2];
	pose[3] = 1000 * pose[3];
	return pose;
end;