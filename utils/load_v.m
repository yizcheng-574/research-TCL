function [ v ] = load_v(path, variable)
if (exist(path) == 2)
    var_struct = load(path, variable);
    name_cell = fieldnames(var_struct);
    v = getfield(var_struct, char(name_cell));
elseif (exist(path) ==0 )
    msgbox('File not exist', 'Error', 'Error');
end
end

