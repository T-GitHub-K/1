function conky_cpuFan()
    local result = tonumber(conky_parse("execi 1 sensors | grep 'Fan' | awk '{print $3}'"))
    if result then
        return result
    else
        return 0
    end
end

function conky_cpuFanColor()
    local cpuFanValue = tonumber(conky_parse("${execi 1 sensors | grep 'CPU Fan' | awk '{print $3}' | cut -d'.' -f1}"))

    if cpuFanValue < 1000 then
        return "${color green}"
    elseif cpuFanValue < 2000 then
        return "${color yellow}"
    else
        return "${color red}"
    end
end

function cpuName()
    local result = conky_parse("${execi 3600 neofetch | grep 'CPU' | cut -c 35-64}")
    return result
end

