;========================================================
; This file reads in a traj file produced by the TC tracker
; and produces a lat-lon plot of trajectories color-coded by intensity
;========================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/glade/u/home/zarzycki/ncl/functions/surfaceWindCorrFactor.ncl"
load "/glade/u/home/zarzycki/ncl/functions/getTrajectoriesGeneric.ncl"
load "/glade/u/home/zarzycki/ncl/functions/mask_tc.ncl"

;========================================================
begin

output_type="pdf"
basin="global"
cutwind=17
factor = surfaceWindCorrFactor(-1,-1,"log")

pres_thresh=910.
basinfilt = 1
maskspacing=1.0
tcMask = mask_tc(0,-999,-999,maskspacing,360)


;thefile="./tempest/trajectories.txt.b.e13.NE30_control.301_320.005ax"
thefile="./tempest/2trajectories.txt.TEST.NE120.0070_0099.005"

ncols = 10                    ; assign number of columns
maxLines = -1
headerDelimStr = "start"
delimStr="tab"
isUnstruc=False
isHeader=False
traj_data = getTrajectoriesGeneric(thefile,ncols,maxLines,headerDelimStr,delimStr,isUnstruc,isHeader)

print("finish reading")
lon = traj_data(:,1,:)
lat = traj_data(:,2,:)
wind = traj_data(:,4,:)*factor
pres = traj_data(:,3,:)/100.
yyyy=  traj_data(:,6,:)
mm= traj_data(:,7,:)
dd= traj_data(:,8,:)
hh= traj_data(:,9,:)

print("mean lat: "+avg(lat))

ndims = dimsizes(lon)
nstorms = ndims(0)
ntimes = ndims(1)


;--------------------------------------------------------
print("Beginning plot sequence")
wks  = gsn_open_wks(output_type,"traj_plotted_color")
gsn_define_colormap(wks,"BlAqGrYeOrReVi200")            ; choose 
map = new(1,graphic)
  
res  = True
res@gsnDraw    = False
res@gsnFrame   = False
res@gsnMaximize = True
res@mpFillOn             = True              ; turn off gray continents
res@mpOutlineOn = True
res@mpGreatCircleLinesOn = True

res@gsnSpreadColors=True
  i = NhlNewColor(wks,0.7,0.7,0.7)      ; add gray to colormap for continents
                                        ; w/o this, they are white, and you
  res@mpMinLonF            =  0.               ; select a subregion
  res@mpMaxLonF            =  360.
  res@mpCenterLonF         = 180.
  res@mpMinLatF           = -80
  res@mpMaxLatF            = 80

  res@mpFillDrawOrder      ="PreDraw"

  res@tiMainString  = "high-res"
 map = gsn_csm_map_ce(wks,res)

;gsn_define_colormap(wks,"rainbow+white+gray")
  polyres               = True          ; poly marker mods desired 
  polyres@gsMarkerIndex = 1            ; choose circle as polymarker
  lineres = True
  
dum = new((/nstorms,ntimes/),graphic)

do i = 0,nstorms-1
  orilat=lat(i,0)
  orilon=min((/lon(i,0),359.0/))

  if (tcMask({orilat},{orilon}) .ne.0) then


do j = 0,ntimes-1
      
thisWind=wind(i,j)

;lineres@gsLineThicknessF = 8.0
; We need to use thinner lines for the global map
if (basin .eq. "global") then
  linethicknesses = (/0.2,0.3,1.3,1.9,1.9, 1.9/)
else if (basin .eq. "tropics") then
  linethicknesses = (/0.1,0.7,1.6,2.0,2.6,3.2/)
else if (basin .eq. "refine") then
  linethicknesses = (/0.1,0.25,0.9,1.3,1.6,2.2/)
else
  linethicknesses = (/0.5,1.0,1.3,1.9,2.3,2.6/)
end if
end if
end if
  linethicknesses = 4.0*linethicknesses

if (.not.ismissing(thisWind))

;  polyres@gsMarkerSizeF = 2.0           ; select size to avoid streaking
  if (thisWind .lt. 17)
    polyres@gsMarkerColor = 0 
    lineres@gsLineColor = 0
    lineres@gsLineThicknessF = linethicknesses(0)
  else if (thisWind .ge. 17 .and. thisWind .lt. 33)
    polyres@gsMarkerColor = 55
    lineres@gsLineColor = 55
    lineres@gsLineThicknessF = linethicknesses(1)
  else if (thisWind .ge. 33 .and. thisWind .lt. 43)
    polyres@gsMarkerColor = 105;(/"yellow2"/)
    lineres@gsLineColor = 105;(/"yellow2"/)
    lineres@gsLineThicknessF = linethicknesses(2)
  else if (thisWind .ge. 43 .and. thisWind .lt. 49)
    polyres@gsMarkerColor = 135 ;(/"orange"/)
    lineres@gsLineColor = 135 ;(/"orange"/)
    lineres@gsLineThicknessF = linethicknesses(3)
  else if (thisWind .ge. 49 .and. thisWind .lt. 58)
    polyres@gsMarkerColor = 151 ;(/"darkorange3"/)
    lineres@gsLineColor = 151 ;(/"darkorange3"/)
    lineres@gsLineThicknessF  = linethicknesses(4)
  else if (thisWind.ge.59.and.thisWind.lt.70)
    polyres@gsMarkerColor = 175;(/"red"/) 
    lineres@gsLineColor = 175;(/"red"/)
    lineres@gsLineThicknessF  = linethicknesses(5)
  else 
    polyres@gsMarkerColor = 190;(/"red"/) 
    lineres@gsLineColor = 190;(/"red"/)
    lineres@gsLineThicknessF  = linethicknesses(5)

  end if
  end if
  end if
  end if
  end if
  end if
  
 txres               = True                            
 txres@txFontHeightF = 0.01             ; Set the font height
  
  if (j .ne. 0) then
    if(thisWind .ge. cutwind.and.lat(i,j).ge.-42.5) then
      dum(i,j) = gsn_add_polyline(wks,map,(/lon(i,j),lon(i,j-1)/),(/lat(i,j),lat(i,j-1)/),lineres)
    end if
  end if
  
end if

end do

end if  ; end if south atlantic
end do

; if we are doing a varres grid, let's push an outline of the atl30x4 grid
;if (modelgrid .eq. "vr") then
;  map = plot_outline_fcn(wks,map,"black",3.0)
;end if

;******************
; Plot a legend   *
;******************

lgres                    = True

lgres@lgAutoManage       = False

lgres@vpWidthF           = 0.08       ; was 0.08        ; width of legend (NDC)
lgres@vpHeightF          = 0.12       ; was 0.08        ; height of legend (NDC)
; lgres@lgBottomMarginF    = 0.17     ; was 0.25

lgres@lgPerimFill        = 0                     ; Use solid fill (0) instead of the default hollow fill
lgres@lgPerimFillColor   = "Background"

;lgres@lgOrientation = "Horizontal"

; lgres@lgBoxMajorExtentF  = 0.4
lgres@lgBoxMinorExtentF  = 0.2	; controls how wide the box holding the legend items (lines and markers) can be in relation to legend

; lgres@lgBoxBackground    = "PaleTurquoise3"

lgres@lgMonoItemType        = False                 ; indicates that we wish to set the item types individually
lgres@lgMonoMarkerIndex     = False
lgres@lgMonoLineThickness   = False
lgres@lgMonoMarkerThickness = False
lgres@lgMonoMarkerSize      = False

;lgres@lgLabelFont             = 0
lgres@lgLabelFontHeightF      = 0.07
lgres@lgLabelFontAspectF      = 1.5
lgres@lgLabelConstantSpacingF = 0.0

legendType = "Markers"
markerSize = .008
markerIndex = 16

if (cutwind .eq. 0) then
lgres@lgItemCount        = 6
;lgres@lgLineDashSegLenF  = 0.8
lgres@lgItemTypes        = (/"Markers","Markers","Markers","Markers","Markers","Markers"/)
lgres@lgMarkerIndexes    = (/      16,      16,      16,      16,      16,      16/)
lgres@lgMarkerThicknesses  = (/    markerSize,    markerSize,    markerSize,    markerSize,    markerSize,    markerSize/)
lgres@lgMarkerColors       = (/ "red",     "darkorange3",   "orange",  "yellow",   "green",    "blue"    /) ; colors for legend lines
;lgres@lgDashIndexes      = (/      0,          0,          0,         0,               0,      0      /) ; dash indexes
legend_labels = (/"Cat. 4/5","Cat. 3","Cat. 2",\
               "Cat. 1","TS","TD"/)
else if (cutwind .eq. 17) then
  lgres@lgItemCount        = 6
  lgres@lgItemTypes        = (/legendType,legendType,legendType,legendType,legendType,legendType/)
  lgres@lgMarkerIndexes    = (/markerIndex,markerIndex,markerIndex,markerIndex,markerIndex,markerIndex/)
  lgres@lgMarkerThicknesses  = (/    markerSize,    markerSize,    markerSize,    markerSize,    markerSize,markerSize/)
  lgres@lgMarkerColors       = (/190, 175, 151, 135,105, 55/)
  legend_labels = (/"Category 5","Category 4", "Category 3","Category 2",\
                 "Category 1","Tropical Storm"/)
else
end if
end if


legend = gsn_create_legend(wks,lgres@lgItemCount,legend_labels,lgres)

amres = True
if (basin .eq. "atlantic") then
amres@amParallelPosF   = 0.43		    ; move legend to the right
amres@amOrthogonalPosF = -.3             ; move the legend down
else if (basin .eq. "tropics") then
amres@amParallelPosF   = 0.21		    ; move legend to the right .37 formerly
amres@amOrthogonalPosF = .27             ; move the legend down
else if (basin .eq. "refine") then
amres@amParallelPosF   = -0.46
amres@amOrthogonalPosF = -0.18
else
amres@amParallelPosF   = 0.45		    ; move legend to the right .37 formerly
amres@amOrthogonalPosF = .27             ; move the legend down
end if
end if
end if

annoid1 = gsn_add_annotation(map,legend,amres)   ; add legend to plot
  
print("Drawing plot")

resP = True
resP@amJust           = "TopRight"
resP@gsnPanelFigureStringsFontHeightF = 0.027
gsn_panel(wks,map,(/1,1/),resP)             ; now draw as one plot

end
