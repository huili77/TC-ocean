
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin

fl = addfile("~/scratch/archive/b.e13.B1850C5CN.ne30_g16.005ax_exact_tcdaily/atm/hist/b.e13.B1850C5CN.ne30_g16.005ax_exact_tcdaily.cam.h0.0330-01.nc","r")
lev = fl->lev


f = addfile("composite_cloud_series_tcdaily_anomclm_4day.0380-0400.nc","r")
number = f->number
cloud_array = f->cloud_array
cloud_array = cloud_array * 100.  ; to percent
cloud_array&lev = lev
cloud_array&time = ispan(-6, 18, 1)
printVarSummary(cloud_array)
ncases = max(number)
print(ncases)

cloud_array = where(cloud_array.eq.0, cloud_array@_FillValue, cloud_array)
cloud_array_mean = dim_avg_n_Wrap(cloud_array, 0)


printVarSummary(cloud_array_mean)

anom_pattern = f->cloud_pattern
anom_pattern = anom_pattern * 100.
anom_pattern!1 = "lev"
anom_pattern!2 = "lat"
anom_pattern!3 = "lon"
anom_pattern&lev  = lev
anom_pattern&lat = ispan(-3,2,1)
anom_pattern&lon = ispan(-2,2,1)
delete(f)
print(lev)

low_cloud = dim_avg_n_Wrap(cloud_array(:,:, 21:29), 2)
low_cloud_pattern = dim_sum_n_Wrap(anom_pattern(:,21:29, :,:), 1)
printVarSummary(low_cloud)


print(cloud_array_mean(5,21:29))
print(cloud_array_mean(6,21:29))

;print(dim_avg_n(cloud_array_mean(:,21:29),1))


mean  = dim_avg_n_Wrap(low_cloud, 0)
std = dim_stddev_n_Wrap(low_cloud, 0)
printVarSummary(mean)


upper = mean + 1.96 * std / sqrt(ncases)
lower = mean - 1.96 * std /sqrt(ncases)

conf = low_cloud(0:1, :)
conf(0,:) = lower
conf(1,:) = upper




;f = addfile("composite_coldwake_series_6hr.nc","r")
;anom_array2 = f->anom_array

    wks = gsn_open_wks("pdf","composite_cloud_series")             
    res = True
    gsn_define_colormap(wks, "cmocean_balance")
    res@vpWidthF = 0.7
    res@vpHeightF = 0.4
    res@gsnDraw = False
    res@gsnFrame = False

    res@trYMinF = -.8
    res@trYMaxF = .8
    res@trXMinF = -6.
    res@trXMaxF = 18.


    res@gsnYRefLine = 0
    res@gsnXRefLine = 0
    res@gsnYRefLineDashPattern = 1
    res@gsnXRefLineDashPattern = 1

    res@xyLineColor = "blue"
    res@xyLineThicknessF = 2.5
    res@tiMainString = "Low cloud amount anomalies"
    res@tiYAxisString  ="Cloud amount (%)"
    res@tiXAxisString = "Days"

    res@tmXMajorGrid = True
    res@tmYMajorGrid = True
    res@tmYMajorGridLineDashPattern = 1.
    res@tmXMajorGridLineDashPattern = 1.
    res@tmYMajorGridLineColor = "grey"
    res@tmXMajorGridLineColor = "grey"

    plot  = gsn_csm_xy(wks,ispan(-6,18,1),mean,res)


    res@xyLineColor = -1
    res@gsnXYFillColors = "lightblue"
    res@gsnXYFillOpacities = 0.4
    plot2  = gsn_csm_xy (wks,ispan(-6, 18, 1),conf,res) ; create filled
    overlay(plot, plot2)
    draw(plot)
    frame(wks)


    res@cnFillOn=True
    res@cnLinesOn = False
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = -2.
    res@cnMaxLevelValF       = 2. 
    res@cnLevelSpacingF = 0.1
    res@trYReverse = True
    res@lbTitleOn = True
    res@lbTitleString = "%"
    res@lbTitleFontHeightF = 0.02
    res@lbTitlePosition  = "Bottom"
    res@pmLabelBarOrthogonalPosF = 0.085

    res@tiYAxisString  ="Level (hPa)"
    res@tiXAxisOffsetYF = 0.17
    res@gsnLeftString = ""
    res@gsnRightString = ""
    res@tmXMajorGrid = True
    res@tmYMajorGrid = True
    res@tiMainString = "Cloud fraction anomalies"

    res@tmXMajorGrid = False
    res@tmYMajorGrid = False

    plot1 = gsn_csm_contour(wks, cloud_array_mean({lev|200:1000}, {time|:}), res)
    draw(plot1)
    frame(wks)

    res@trYMinF = -2.
    res@trYMaxF = 3.
    res@trXMinF = -2.
    res@trXMaxF = 2.

    
   do i = 21, 29
    res@tiMainString = "level = "+lev(i)
   plot2 = gsn_csm_contour(wks,anom_pattern(5,i, :,:),res)
   draw(plot2)
   frame(wks)
   end do

end

   
