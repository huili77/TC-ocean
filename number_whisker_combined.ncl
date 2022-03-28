
; --------------------------------------------------
; a box whisker plot for the storm number
; we will be looking at total hurricane and major hurricane
; looking at all three models, maybe observations too?
;
; I need the median, the 25 and 75 percentile
; --------------------------------------------------


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/glade/u/home/zarzycki/ncl/functions/getTrajectoriesGeneric.ncl"
load "/glade/u/home/zarzycki/ncl/functions/mask_tc.ncl"
load "/glade/u/home/zarzycki/ncl/functions/surfaceWindCorrFactor.ncl"

;************************************************
begin

basin = (/"at","ep","ni","nwp","si","sp"/)
; the basins from observatios are at, ep, io, wp, sh

storm = new((/2,5,59/),"float")     ; (model,basin,years)
storm = 0.
major  = storm

box_s = new((/2,5,5/),float)     ; (model, basin, 5 statistics)
box_m = box_s


;--------------------------------------------------
; read in observations
;------------------------------------------------------------

fo = addfile("obs_tc_num_whisker.nc","r")
storm(0,:,0:29) = fo->storm
major(0,:,0:29) = fo->major

;--------------------------------------------------
; read in TC cases and get intensity and number
; 
;--------------------------------------------------
factor = surfaceWindCorrFactor(-1,-1,"log")

pres_thresh=910.
maskspacing=1.0
tcMask = mask_tc(0,-999,-999,maskspacing,360)

thefile="../tempest/2trajectories.txt.TEST.NE120.combined"

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

do ii = 0,nstorms-1
ibasin  = 999
if (yyyy(ii,0).ge.101.and.yyyy(ii,0).le.129) then
iy = tointeger(yyyy(ii,0) - 101)  ; year 70-99
else if (yyyy(ii, 0).lt.100)
iy = tointeger(yyyy(ii,0) - 70 +29)  ; year 70-99
end if
end if
orilat=lat(ii,0)
orilon=min((/lon(ii,0),359.0/))
tcmask = tcMask({orilat},{orilon})

if (tcmask.eq.3) then  ; central pacific counts for nwp
  ibasin = 3
else if (tcmask.eq.5) then ; indian ocean
  ibasin = 2
else if (tcmask.eq.6.or.tcmask.eq.7) then  ; southern hemisphere
  ibasin = 4
else
  ibasin  = tcmask-1
end if
end if
end if

print(iy)
if (ibasin.ge.0.and.ibasin.le.4) then
   storm(1,ibasin,iy) = storm(1,ibasin,iy) + 1
   max_uv = max(wind(ii,:))

  if (max_uv.ge.49.) then
   major(1,ibasin,iy) = major(1,ibasin,iy) + 1 
  end if

end if

print("------------------------------")
end do
print(storm(1,:,25))
storm(1,:,55) = storm(1,:,54)
major(1,:,55) = major(1,:,54)
print(storm(1,:,25))

storm(0,:,30:58) = storm@_FillValue
;--------------------------------------------------
; now calculate the median and the percentiles, and the extremes
;--------------------------------------------------

opt = True
opt@PrintStat = True

stats_s = new((/2,5,30/),float)  ;(model, ibasin, return from function)
stats_m = stats_s

do ns = 0,1
  do nb = 0,4
  stats_s(ns,nb,:) = stat_dispersion(storm(ns,nb,:),opt)
  stats_m(ns,nb,:) = stat_dispersion(major(ns,nb,:),opt)
  end do
end do


;--------------------------------------------------
; count TC number and stadard deviation according to intensity
;--------------------------------------------------
avg_s = new((/2,5/),float)  ; average storm number (model, ibasin)
avg_m = avg_s
std_s = avg_s
std_m = avg_s


do ns = 0,1
 do nb= 0,4
  avg_s(ns, nb) = stats_s(ns, nb, 0) 
  avg_m(ns, nb) = stats_m(ns, nb, 0)
  std_s(ns, nb) = stats_s(ns, nb, 1)
  std_m(ns, nb) = stats_m(ns, nb, 1)
end do
end do

print("average storm number:")
print(avg_s)
print("storm number std: ")
print(std_s)
print("average major TC number:")
print(avg_m)
print("major TC number std: ")
print(std_m)

;--------------------------------------------------
; get global average
;--------------------------------------------------

global_s = dim_sum_n_Wrap(storm,1)   ;storm(data, ibasin, years)
global_m = dim_sum_n_Wrap(major,1)

global_stats_s = new((/2,30/),float)  ;(model, ibasin, return from function)
global_stats_m = new((/2,30/),float)


do ns = 0,1
  global_stats_s(ns,:) = stat_dispersion(global_s(ns,:),opt)
  global_stats_m(ns,:) = stat_dispersion(global_m(ns,:),opt)
end do
 
avg_s_global = new(2, float)
avg_m_global = avg_s_global
std_s_global = avg_s_global
std_m_global = avg_s_global

do ns = 0,1
avg_s_global(ns) = global_stats_s(ns, 0)
avg_m_global(ns) = global_stats_m(ns, 0)
std_s_global(ns) = global_stats_s(ns, 1)
std_m_global(ns) = global_stats_m(ns, 1)
end do

print("global average s = ")
print(avg_s_global)
print("global_std s = ")
print(std_s_global)
print("global_average m = ")
print(avg_m_global)
print("global_std m = ")
print(std_m_global)


do ns = 0,1
 do nb= 0,4
 box_s(ns,nb,0) = stats_s(ns,nb,2)
 box_s(ns,nb,1) = stats_s(ns,nb,6)
 box_s(ns,nb,2) = stats_s(ns,nb,8)
 box_s(ns,nb,3) = stats_s(ns,nb,10)
 box_s(ns,nb,4) = stats_s(ns,nb,14)

 box_m(ns,nb,0) = stats_m(ns,nb,2)
 box_m(ns,nb,1) = stats_m(ns,nb,6)
 box_m(ns,nb,2) = stats_m(ns,nb,8)
 box_m(ns,nb,3) = stats_m(ns,nb,10)
 box_m(ns,nb,4) = stats_m(ns,nb,14)

 end do
end do

box_s_t = dim_sum_n_Wrap(box_s,1)
box_m_t = dim_sum_n_Wrap(box_m,1)

print(box_s_t)
print(box_m_t)

;--------------------------------------------------
; now plot babay
; we will have 5 panels, each for a ibasin
;   in each panel, we will have storms and major 
;     for each storm or major, we will have 4 datasets(obs, coupled, atm,slab)
;---------------------------\-----------------------

wks = gsn_open_wks("x11","box_plot")

res           = True
;res@tmXBLabels = (/"","","TCs","","","","major TCs",""/)
res@trXMinF    = 0
res@trXMaxF    = 10
res@trYMinF     = 0
res@trYMaxF     = 45
res@tmXBLabelFontHeightF  = 0.03
res@tmYLLabelFontHeightF = 0.03

;   colors = (/(/0.0, 0.0, 0.0/), (/141, 160,203/), (/252, 141, 98/), (/102, 194, 165/)/)


;  colors = (/(/0.0, 0.0, 0.0/), (/117, 112,179/),(/217, 95, 2/), (/27, 158, 119/)/)
;  colors = colors / 255.
;  colors = (/"(/0, 0, 0/)", "(/0.4588,0.4392,0.70196/)", "(/0.85098, 0.37255,0.00784/)", "(/0.10588, 0.6196, 0.46666/)"/) 
  colors = (/"(/0.10588, 0.6196, 0.46666/)", "(/0.85098, 0.37255,0.00784/)"/) 
;print(dimsizes(colors))


  opti          = True			
  opti@boxWidth = 0.7				; Width of box (x units)
  opti@boxColors = colors

llres = True
llres@gsLineThicknessF = 3.


plot = new(6,graphic)
plotm = plot

title = (/"AT","EP","NI","WP","SH"/)
do nb = 0,4
res@tiMainString  = ""+title(nb)
res@tmXBLabels   = (/"All TCs",""/)
plot(nb+1) = boxplot(wks,(/2,3/),box_s(:,nb,:),opti, res, llres)
res@tmXBLabels   = (/"Major TCs",""/)
plotm(nb+1) = boxplot(wks,(/7,8/),box_m(:,nb,:),opti, res, llres)
overlay(plot(nb+1),plotm(nb+1))
end do

res@trYMinF     = 0
res@trYMaxF     = 140
res@tiMainString = "Global"
res@tmXBLabels   = (/"All TCs",""/)
plot(0) =boxplot(wks,(/2,3/),box_s_t,opti, res, llres)
res@tmXBLabels   = (/"Major TCs",""/)
plotm(0) = boxplot(wks,(/7,8/),box_m_t,opti, res, llres)
overlay(plot(0),plotm(0))

lgres            = True
lgres@vpWidthF   = 0.08
lgres@vpHeightF  =0.08
lgres@lgAutoManage = False
lgres@lgLineThicknessF   = 3.
lgres@lgPerimOn  =True
lgres@lgTitleFontHeightF = 0.01
lgres@lgLineColors   = colors(::-1)
lgres@lgDashIndexes  = (/0,0/)
lgres@lgLineLabelStrings = (/"",""/)
lgres@lgLabelFontHeightF   = 0.06
 
resp    = True
resp@gsnMaximize  = True
gsn_legend_ndc(wks,2,(/" CESM"," OBS"/),0.25,0.95,lgres)
resp@gsnPanelYWhiteSpacePercent = 8
gsn_panel(wks,plot,(/3,3/),resp)

end


