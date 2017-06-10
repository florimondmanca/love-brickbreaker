--- Simple logging object with various levels of announces

local Log = {
    pre = '',
}

function Log._write(status, msg)
    print((Log.pre and Log.pre .. ' ' or '') .. '(' .. status .. '): ' .. msg)
end

function Log.info(msg) Log._write('Info', msg) end
function Log.debug(msg) Log._write('Debug', msg) end
function Log.warning(msg) Log._write('Warning', msg) end

return Log
