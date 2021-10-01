module Js2x

# Write your package code here.

export Profile, ProfileDataPoint, point_counts, avg_brightness, laser_on_times, read_edger_board

const MAX_LENGTH = 21 
const MAX_PROFILES = MAX_LENGTH * 12
const MAX_VERTICAL = 243
mutable struct ProfileDataPoint
    x::Int32
    y::Int32
    brightness::Int32
end
mutable struct Profile
	sequenceNumber::Int32
	location::Int32
    sendLocation::Int32
	laserOnTime::Int32
	timeInHead::Int32
	inputs::Int32
	flags::Int32
	laserIndex::Int32
	reserved2::Int32
	numberPoints::Int32
	data::Vector{ProfileDataPoint}
end

point_counts(profiles) = map(prof->prof.numberPoints,profiles)
laser_on_times(profiles) = map(prof->prof.laserOnTime,profiles)
avg_brightness(profiles) =  map(prof->mean(map(pd->pd.brightness,prof.data)),profiles)

function read_profile(file)
    sequenceNumber = read(file,Int32)
    location = read(file,Int32)
    sendLocation = read(file,Int32)
    laserOnTime = read(file,Int32)
    timeInHead = read(file,Int32)
    inputs = read(file,Int32)
    flags = read(file,Int32)
    laserIndex = read(file,Int32)
    reserved2 = read(file,Int32)
    numberPoints = read(file,Int32)
    data = Vector{ProfileDataPoint}(undef,numberPoints)
    for i = 1:MAX_VERTICAL
        x = read(file,Int32)
        y = read(file,Int32)
        brightness = read(file,Int32)
        if (i <= numberPoints)
            data[i] = ProfileDataPoint(x,y,brightness)
        end
    end
    return Profile(sequenceNumber,location,sendLocation,laserOnTime,timeInHead,inputs,flags,laserIndex,reserved2,numberPoints,data)
end


function read_edger_board(filename)
    file = open(filename)
    seek(file,796184)
    profiles = Array{Profile}(undef,MAX_PROFILES,2)
    for i=1:MAX_PROFILES
        for j = 1:2
            profiles[i,j] = read_profile(file)
        end
    end
    return profiles
end

end
