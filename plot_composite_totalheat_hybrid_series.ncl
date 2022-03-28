load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin

; shorwave radiation
f = addfile("composite_flux_series_hybrid_hf_37days.0042-0052_new.nc","r")
fsns_array = f->fsns_array
flns_array = f->flns_array
lhflx_array = f->lhflx_array
shflx_array = f->shflx_array
number = f->number
print(fsns_array)
delete(f)


f = addfile("composite_shf_series_hybrid_hf_37days.0042-0052.nc","r")
shf_array = f->shf_array
delete(f)
printVarSummary(shf_array)

array = new((/6, 38/), float)
array!0 = "data"
array!1 =  "time"
array&time = ispan(-6, 31,1)

array(0,:) = fsns_array
array(1,:) = flns_array
array(2,:) = lhflx_array
array(3,:) = shflx_array
array(4,:) = fsns_array - flns_array - shflx_array - lhflx_array
array(5,:) = shf_array

print("total 7-37")
print(dim_sum_n(array(:,7:37),1))
print(array(4,:))
print(pp)

    wks = gsn_open_wks("pdf","composite_sfc_energy_cpl")             
    res = True
    res@vpWidthF = 0.7
    res@vpHeightF = 0.4
    res@gsnDraw = True
    res@gsnFrame = False
    res@trYMinF = -100.
    res@trYMaxF = 60.
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
    res@pmLegendDisplayMode = "Never"
    res@xyExplicitLegendLabels = (/" SW"," LW"," LHF"," SHFLX"," Total"/)
    res@lgItemOrder= (/4,3,2,1,0/)
    res@pmLegendParallelPosF   = .82               ; move units right
    res@pmLegendOrthogonalPosF = -0.65            ; move units down
    res@lgPerimOn = False
    res@pmLegendWidthF         = 0.1                ; Change width and
    res@pmLegendHeightF        = 0.15                ; height of legend.
    res@lgLabelFontHeightF     = .018              ; change font height
    res@lgTitleOn              = False                ; turn on legend title

    res@tiMainString = "High-res Coupled"
    plot  = gsn_csm_xy(wks,ispan(-6,31,1),array(0:4,:),res)
    frame(wks)


   delete(res@trYMinF)
   delete(res@trYMaxF)
   delete(res@trXMaxF)
   delete(res@trXMinF)



end

   
