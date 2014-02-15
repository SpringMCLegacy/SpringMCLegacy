function table.contains(table, element)   
	for i=1, #table do     
		if table[i] == element then       
			return true     
		end   
	end   
	return false 
end
