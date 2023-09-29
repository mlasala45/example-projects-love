saveutil = {}

function saveutil.save_registered_list(savedata, name, list)
	for i=1,#list do
		savedata[name][i] = list[i].uid
	end
end