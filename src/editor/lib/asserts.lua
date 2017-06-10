local asserts = {}

function asserts.required(value, name)
    assert(value, 'argument ' .. name .. ' is required')
end

function asserts.hasType(type, value, name)
    assert(type(value) == type, name .. ' expected to be ' .. type .. ' (was ' .. type(value) .. ')')
end

return asserts
