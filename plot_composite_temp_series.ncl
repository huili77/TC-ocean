load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin


case = "b.e13.B1850C5CN.ne30_g16.005ax_exact_tcdaily"
ft = addfile("/glade/scratch/huili7/archive/"+case+"/ocn/hist/"+case+".pop.h.0371-01.nc","r")
z_t = ft->z_t(0:50)
z_t = z_t * 0.01
print(z_t)

f = addfile("composite_temp_series_tcdaily_4day.350-360_20deg.nc","r")
;number = f->number
anom_array = f->temp_array
anom_array!0 = "time"
anom_array!1 = "z_t"
anom_array!2 = "lat"
anom_array!3 = "lon"
anom_array&time = ispan(0, 29,1)
anom_array&lat = ispan(-10,9,1)
anom_array&lon = ispan(-10,9,1)
anom_array&z_t = z_t
delete(f)


;------
f = addfile("composite_hmxl_series_tcdaily_4day.350-360_20deg.nc","r")
;number = f->number
hanom_array = f->hmxl_array
hmxl0_array  = f->domain0_arrray

hanom_array!0 = "time"
hanom_array!1 = "lat"
hanom_array!2 = "lon"
hanom_array&time = ispan(0, 29,1)
hanom_array&lat = ispan(-10,9,1)
hanom_array&lon = ispan(-10,9,1)


hmxl0_array!0 = "time"
hmxl0_array!1 = "lat"
hmxl0_array!2 = "lon"
hmxl0_array&time = ispan(0, 29,1)
hmxl0_array&lat = ispan(-10,9,1)
hmxl0_array&lon = ispan(-10,9,1)
printVarSummary(hmxl0_array)
delete(f)

hmxl_array = hmxl0_array
hmxl_array = hmxl0_array + hanom_array

;-------------------

ave = anom_array(:,:,0,0)
ave = wgt_areaave(anom_array({:},{:},{-10:9},{-10:9}),1,1,0)
printVarSummary(ave)

ave_hmxl0 = hmxl0_array(:,0,0)
ave_hmxl0 = wgt_areaave(hmxl0_array({:},{-10:9},{-10:9}),1,1,0)

ave_anom = ave_hmxl0
ave_anom =  wgt_areaave(hanom_array({:},{-10:9},{-10:9}),1,1,0)


ave_hmxl = ave_anom
ave_hmxl = ave_hmxl0 + ave_anom

print(hmxl_array(3,:,10))

;--------------------------
    wks = gsn_open_wks("pdf","composite_temp_sections_series")             
    gsn_define_colormap(wks, "cmocean_balance")
    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@vpWidthF  = 0.7
    res@vpHeightF = 0.4
   res@cnLinesOn = False
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = -0.1
   res@cnMaxLevelValF       = 0.1
   res@cnLevelSpacingF = 0.01

    res@cnFillOn = True
   res@trYReverse = True
   res@tiMainString  = "Composite T anomalies"
   res@tiYAxisString  = "Depth (m)"
   res@tiXAxisString = "Days"
   res@tiXAxisOffsetYF = 0.17


   res@lbTitleOn  = True
   res@lbTitleString ="~S~o~N~C"
   res@lbTitleFontHeightF = 0.02
   res@lbTitlePosition  = "Bottom"
   res@pmLabelBarOrthogonalPosF = 0.085


    plot = gsn_csm_contour(wks, ave({z_t|0:400}, {time|:}),res)

    res@xyLineColor = "Black"
    res@xyLineThicknessF = 3.
    plot_h = gsn_csm_xy(wks, ave_hmxl0&time, ave_hmxl0, res)
    res@xyDashPattern = 1
    plot_h1 = gsn_csm_xy(wks, ave_hmxl&time, ave_hmxl0, res)
    overlay(plot, plot_h)
    overlay(plot, plot_h1)
    draw(plot)
    frame(wks)

   res@cnMinLevelValF       = -1.
   res@cnMaxLevelValF       = 1.
   res@cnLevelSpacingF = 0.05

   res@gsnSpreadColors = True
;   res@gsnSpreadColorEnd = -10

;     do i = 0, 29
;       res@tiMainString="day = "+(i-1)

;     plot2 = gsn_csm_contour(wks,anom_array(i,:, :,10),res)
;  ;   plot2h = gsn_csm_xy(wks, ispan(-10, 9, 1), hmxl_array(i,:,10), res)
;  ;   overlay(plot2, plot2h)
; draw(plot2)
;     frame(wks)
;     end do 

end

   
