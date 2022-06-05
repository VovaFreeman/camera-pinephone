#!/usr/bin/env sh
#requires v4l-utils imagemagick ffmpeg ristretto                                         
#2022 VovaFreeman based on
#2020 slvr and amom based on work from                                                  
#https://git.sr.ht/~martijnbraam/python-pinecamera     

# create a launcher somewhere like
# /usr/share/applications/camera.desktop 
# to access from a GUI

newfilename=IMG_$(date +%Y%m%d_%H%M%S).jpg ;
saveDir=$HOME/Pictures ;
guiViewer=ristretto ;

cd $saveDir; 

#reset the media link
media-ctl -d /dev/media1 -r ;
media-ctl -d /dev/media1 -l '"ov5640 3-004c":0->"sun6i-csi":0[1]' ;

media-ctl -d /dev/media1 --set-v4l2 '"ov5640 3-004c":0[fmt:UYVY8_2X8/1920x1080@1/20]' ;
v4l2-ctl --device /dev/video2 --set-fmt-video="width=1920,height=1080,pixelformat=UYVY" ;

bash -c 'sleep 2; v4l2-ctl -z platform:1cb0000.csi -d "ov5640 3-004c" -c focus_automatic_continuous=1,auto_focus_start=1' & 

ffplay -f v4l2 -framerate 20 -video_size 1920x1080 -i /dev/video2 -exitonmousedown -vf "transpose=1" -x 640 -y 360 ;

bash -c 'sleep 2; v4l2-ctl -z platform:1cb0000.csi -d "ov5640 3-004c" -c focus_automatic_continuous=1,auto_focus_start=1' & 

ffmpeg -f v4l2 -framerate 20 -video_size 1920x1080 -ss 00:00:02.5 -i /dev/video2 -frames:v 1 -vf "transpose=1" $newfilename ;
$guiViewer $newfilename &
rm -rf /tmp/frame.raw ;
