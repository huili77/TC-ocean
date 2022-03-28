;========================================================
; This file reads in a traj file produced by the TC tracker
; and produces a lat-lon plot of trajectories color-coded by intensity
;========================================================
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/glade/u/home/zarzycki/ncl/functions/trackDensity.ncl"
load "/glade/u/home/zarzycki/ncl/functions/surfaceWindCorrFactor.ncl"
load "/glade/u/home/zarzycki/ncl/functions/getTrajectoriesGeneric.ncl"
load "/glade/u/home/zarzycki/ncl/functions/mask_tc.ncl"

;========================================================
begin

output_type="pdf"
basin="global"
cutwind=17;0.0
factor = surfaceWindCorrFactor(-1,-1,"log")

pres_thresh=910.
basinfilt = 1
maskspacing=1.0
tcMask = mask_tc(0,-999,-999,maskspacing,360)

files = systemfunc("ls ../../obs_tracks/trim_obs_traj_*.nc"); 1985-2014
f = addfiles(files,"r")
ListSetType(f, "join")

lat = f[:]->lat
lon = f[:]->lon
wind = f[:]->wind

dims = dimsizes(lon)  ; times, storms
nyears = dims(0)
ntimes = dims(1)
nstorms = dims(2)
printVarSummary(wind)


;--------------------------------------------------------
print("Beginning plot sequence")
wks  = gsn_open_wks(output_type,"traj_plotte_obsd_color")
gsn_define_colormap(wks,"BlAqGrYeOrReVi200") 
map = new(1,graphic)
  
res  = True
res@gsnDraw    = False
res@gsnFrame   = False
res@gsnMaximize = True
res@mpFillOn             = True              ; turn off gray continents
res@mpOutlineOn = True
;res@mpGreatCircleLinesOn = True
 

i = NhlNewColor(wks,0.7,0.7,0.7)      ; add gray to colormap for continents        
res@mpMinLonF            =  0.             
res@mpMaxLonF            =  360.
res@mpCenterLonF         = 180.
res@mpMinLatF           = -80
res@mpMaxLatF            = 80
res@mpFillDrawOrder      ="PreDraw"

res@tiMainString = "OBS"
map = gsn_csm_map_ce(wks,res)

  polyres               = True          ; poly marker mods desired 
  polyres@gsMarkerIndex = 1            ; choose circle as polymarker
  lineres = True
  
  dum = new((/nyears, ntimes,nstorms/),graphic)

do iy = 0, nyears-1
    print("year "+iy)
  do j = 0,nstorms-1
    maxwind = max(wind(iy,:,j))
;    if (maxwind.ge.50) then
 ;     print("maxwind = "+maxwind)
      do i = 0,ntimes-1
        thisWind=wind(iy, i,j)

        linethicknesses = (/0.2,0.3,1.3,1.9,1.9, 1.9/)
        linethicknesses = 4.0*linethicknesses

        if (.not.ismissing(thisWind))

;  polyres@gsMarkerSizeF = 2.0           ; select size to avoid streaking
          if (thisWind .lt. 17)
            polyres@gsMarkerColor =0
            lineres@gsLineColor = 0
            lineres@gsLineThicknessF = linethicknesses(0)
          else if (thisWind .ge. 17 .and. thisWind .lt. 33)
            polyres@gsMarkerColor = 55 
            lineres@gsLineColor = 55
            lineres@gsLineThicknessF = linethicknesses(1)
          else if (thisWind .ge. 33 .and. thisWind .lt. 43)
            polyres@gsMarkerColor = 105
            lineres@gsLineColor = 105
            lineres@gsLineThicknessF = linethicknesses(2)
          else if (thisWind .ge. 43 .and. thisWind .lt. 49)
            polyres@gsMarkerColor = 135
            lineres@gsLineColor = 135
            lineres@gsLineThicknessF = linethicknesses(3)
          else if (thisWind .ge. 49 .and. thisWind .lt. 58)
            polyres@gsMarkerColor = 151
            lineres@gsLineColor = 151
            lineres@gsLineThicknessF  = linethicknesses(4)
          else if (thisWind.ge.58.and.thisWind.lt.79)
            polyres@gsMarkerColor = 175 
            lineres@gsLineColor = 175
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
  
  if (i .ne. 0) then
    if(thisWind .ge. cutwind) then
;      print( "plot ah")
      dum(iy, i,j) = gsn_add_polyline(wks,map,(/lon(iy,i,j),lon(iy, i-1,j)/),(/lat(iy, i,j),lat(iy, i-1,j)/),lineres)
    end if
  end if
  
end if

end do
;end if
end do
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
  legend_labels = (/"Category 5","Category4","Category 3","Category 2",\
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
amres@amParallelPosF   = 0.45	
amres@amOrthogonalPosF = .27             ; move the legend down
end if
end if
end if

annoid1 = gsn_add_annotation(map,legend,amres)   ; add legend to plot
  
print("Drawing plot")


;---------
; plot the basin boundaries
;----------------
  ; 1 = ATL  lat(0, 45), lon(257, 355) four corners: (257,22), (257, 45), (355,45),(355, 0), (295, 0)
  ; 2 = EPAC five corners (220,0), (220, 45), (257, 45)) + (295,0),(257, 22) 
  ; 3 = CPAC+ WPAC   (100, 0) (100, 45), (220 0) (220, 45)
  ; 5 = NIO       (30, 0) (30, 45), (100, 0) (100, 45)
  ; 6 = SH      (30,0), (30, -45) (290, 0) (290, -45)

lres = True
lres@gsLineColor = "olivedrab"
lres@gsLineThicknessF = 3.
;lres@gsLineDashPattern = 1

res@mpGreatCircleLinesOn = False

xpts = (/257., 257., 355., 355., 287., 257./)
ypts = (/22., 45., 45., 5., 5., 22./)
dum_at = new(5, graphic)
do i = 0, 4
  dum_at(i) = gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), lres)
end do
delete(xpts)
delete(ypts)

xpts = (/220., 220., 257., 257., 287., 220./)
ypts = (/5., 45., 45., 22., 5., 5./)
dum_ep = new(5, graphic)
do i = 0, 4
  dum_ep(i) = gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), lres)
end do
delete(xpts)
delete(ypts)


xpts = (/100., 100., 220., 220., 100./)
ypts = (/5., 45., 45., 5., 5./)
dum_nwp = new(4, graphic)
do i = 0, 3
  dum_nwp(i) = gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), lres)
end do
delete(xpts)
delete(ypts)


xpts = (/30., 30., 100., 100., 30./)
ypts = (/5., 25., 25., 5., 5./)
dum_nio = new(4, graphic)
do i = 0, 3
  dum_nio(i) = gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), lres)
end do
delete(xpts)
delete(ypts)


xpts = (/30., 30., 200., 290., 290.,200., 30./)
ypts = (/-45., -5., -5.,-5., -45., -45., -45./)
dum_sh = new(6, graphic)
do i = 0, 5
  dum_sh(i) = gsn_add_polyline(wks, map, xpts(i:i+1), ypts(i:i+1), lres)
end do

;------------
; add text
 txres               = True                     ; text mods desired
 txres@txFontHeightF = 0.02                     ; font smaller. default big
 txres@txFontColor = "black"
 dum_t1 = gsn_add_text(wks,map,"NA",330.,10.0,txres) 
 dum_t2 = gsn_add_text(wks,map,"EP",230.,40.0,txres) 
 dum_t3 = gsn_add_text(wks,map,"NWP",115.,40.0,txres) 
 dum_t4 = gsn_add_text(wks,map,"NI",40.,19.0,txres) 
 dum_t5 = gsn_add_text(wks,map,"SH",265.,-10.0,txres) 




resP = True
resP@amJust           = "TopRight"
resP@gsnPanelFigureStringsFontHeightF = 0.027
gsn_panel(wks,map,(/1,1/),resP)             ; now draw as one plot

end
