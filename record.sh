#!/bin/bash

##config

resolution="$(xdpyinfo | grep dimensions | awk '{print $2}')" #the default recording resolution
display=":0.0" #which monitor to record
fps=60 #default framerate per second
enableVideo=true #enable or disable video by default

#input and output
#if you don't want to use easyeffects run this command {ffmpeg -sources pulse} to find which input and output you can use
#TODO make it more "automatic"
input=easyeffects_source #input device
enableInput=fales #enable or disable output by default
output=easyeffects_sink.monitor #output device
enableOutput=false #enable or disable input by default

#location name and format
location=Videos/screenrecord #default save location
name=$(date +%F-%H-%M-%S) #default name
format=mp4 #default format

codec="libx264 -pix_fmt yuv420p" #default codec
##

##options
while getopts r:f:vViIoOn:l:f:c: flag
do
    case "${flag}" in
	r) resolution=${OPTARG};;
	s) fps=${OPTARG};;
	v) enableVideo=true;;
	V) enableVideo=false;;
	i) enableInput=true;;
	I) enableInput=false;;
	o) enableOutput=true;;
	O) enableOutput=false;;
	n) name=${OPTARG};;
	l) location=${OPTARG};;
	f) format=${OPTARG};;
	c) codec=${OPTARG};;
    esac
done

if [ $enableVideo == true ]
then
    videoInput="-f x11grab -framerate $fps -s $resolution -i $display"
fi

if [ $enableInput == true ]
then
    pulseInput="-f pulse -i $input"
fi

if [ $enableOutput == true ]
then
    pulseOutput="-f pulse -i $output"
fi

if [[ $enableInput == true && $enableOutput == true ]]
then
    mix="-filter_complex "[1:a:0][2:a:0]amix=2[aout]" -map 0:V:0 -map "[aout]""
fi

#execute
ffmpeg $videoInput $framerate $pulseInput $pulseOutput $mix -c:v $codec $location/$name.$format
