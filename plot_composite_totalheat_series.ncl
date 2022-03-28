load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin

; shorwave radiation
f = addfile("composite_fsns_series_tcdaily_anomclm_37day.330-399.nc","r")
fsns_array = f->fsns_array
fsns_pattern = f->fsns_pattern
delete(f)

; long wave radiation
f = addfile("composite_flns_series_tcdaily_anomclm_37day.330-399.nc","r")
flns_array = f->flns_array
flns_pattern = f->flns_pattern
delete(f)

; latent heat
f = addfile("composite_lhflx_series_tcdaily_anomclm_38day.330-399.nc","r")
lhflx_array = f->lhf_array
lhflx_pattern = f->lhf_pattern
delete(f)

; sensible heat
f = addfile("composite_shflx_series_tcdaily_anomclm_37day.330-399.nc","r")
shflx_array = f->shflx_array
shflx_pattern = f->shflx_pattern
delete(f)


;; toal surface heat
f = addfile("composite_shf_series_tcdaily_37days.330-399.nc","r")
shf_array = f->shf_array
;shf_pattern = f->shf_pattern
delete(f)
printVarSummary(shf_array)

; latent heat from ne120 coupled
f=addfile("composite_lhflx_series_hybrid.0050-0072.nc","r")
lhflx_array2 = f->lhf_array
lhflx_pattern2 = f->lhf_pattern

array = new((/5, 38/), float)
array!0 = "data"
array!1 =  "time"
array&time = ispan(-6, 31,1)

array(0,:) = fsns_array
array(1,:) = flns_array
array(2,:) = lhflx_array
array(3,:) = shflx_array
array(4,:) = fsns_array - flns_array - shflx_array - lhflx_array

print(dim_sum_n(array(:,:),1))
print(pp)

anom_pattern = new((/5, 11, 6, 5/), float)
anom_pattern!1= "time"
anom_pattern!2 = "lat"
anom_pattern!3 = "lon"
anom_pattern&lat = ispan(-3,2,1)
anom_pattern&lon = ispan(-2,2,1)


anom_pattern(0,:,:,:) = fsns_pattern
anom_pattern(1,:,:,:) = flns_pattern
anom_pattern(2,:,:,:) = lhflx_pattern
anom_pattern(3,:,:,:) = shflx_pattern
anom_pattern(4,:,:,:) = fsns_pattern - flns_pattern -lhflx_pattern -shflx_pattern



;f = addfile("composite_coldwake_series_6hr.nc","r")
;anom_array2 = f->anom_array

    wks = gsn_open_wks("x11","composite_sfc_energy_tc")             
    res = True
    res@vpWidthF = 0.7
    res@vpHeightF = 0.4
    res@gsnDraw = True
    res@gsnFrame = False
    res@trYMinF = -40
    res@trYMaxF = 30
    res@trXMinF = -7.
    res@trXMaxF = 31
    res@tiYAxisString = "W/m~S~2"
    res@tiXAxisString = "Days"
    res@gsnYRefLine = 0
    res@gsnXRefLine = 0
    res@gsnYRefLineDashPattern = 1
    res@gsnXRefLineDashPattern = 1
    res@xyLineThicknesses = (/3., 3., 3., 3., 3./)
    res@xyDashPatterns = 0.
    res@tmXMajorGrid = True
    res@tmYMajorGrid = True
    res@tmXMajorGridLineColor = "grey"
    res@tmXMajorGridLineDashPattern = 2.
    res@tmYMajorGridLineColor = "grey"
    res@tmYMajorGridLineDashPattern = 2.


    res@xyLineColors = (/"orange","blue","red","darkgreen","black"/)
    res@pmLegendDisplayMode = "Always"
    res@xyExplicitLegendLabels = (/" SW"," LW"," LHF"," SHF"," Total"/)
    res@lgItemOrder= (/4,3,2,1,0/)
    res@pmLegendParallelPosF   = .82               ; move units right
    res@pmLegendOrthogonalPosF = -0.65            ; move units down
    res@lgPerimOn = False
    res@pmLegendWidthF         = 0.1                ; Change width and
    res@pmLegendHeightF        = 0.15                ; height of legend.
    res@lgLabelFontHeightF     = .018              ; change font height
    res@lgTitleOn              = False                ; turn on legend title
    res@tiMainString = "Added-TC"
    plot  = gsn_csm_xy(wks,ispan(-6,31,1),array(0:4,:),res)
    frame(wks)


   delete(res@trYMinF)
   delete(res@trYMaxF)
   delete(res@trXMaxF)
   delete(res@trXMinF)

   res2 = True
   gsn_define_colormap(wks, "cmocean_thermal")
   res2@vpWidthF = 0.5
   res2@vpHeightF = 0.5
   res2@gsnSpreadColors = True
   res2@gsnSpreadColorStart = 20
   res2@cnFillOn = True
   res2@cnLinesOn = False
   res2@cnLevelSelectionMode = "ManualLevels"
   res2@cnMinLevelValF       = -26.
   res2@cnMaxLevelValF       = 26.
   res2@cnLevelSpacingF  = 1.

   res2@tmXBMode = "Explicit"
   res2@tmXBValues = (/0., 1., 2., 3., 4./)
   res2@tmXBLabels = (/-2., -1., 0., 1., 2/)

   res2@tmYLMode = "Explicit"
   res2@tmYLValues = (/0., 1., 2., 3., 4., 5./)
   res2@tmYLLabels = (/-2.5, -1.5, -0.5, 0.5,1.5, 2.5/)
   
   res2@lbTitleString = "(W/m~S~2~N~)"
   res2@lbTitlePosition = "Bottom"
   res2@lbTitleFontHeightF = 0.018
   do i = 0, 10

   res2@tiMainString = "day = "+(i-1)
;   plot2 = gsn_csm_contour(wks,lhflx_pattern(i, :,:),res2)
;   plot3 = gsn_csm_contour(wks,lhflx_pattern2(i, :,:),res2)

   end do

end

   
