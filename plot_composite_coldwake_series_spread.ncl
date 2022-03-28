load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 

begin


f = addfile("composite_coldwake_series_daily_dayclm_cntl_spread_intense_380-389.nc","r")
number = f->number
anom_array = f->anom_array  ; case, 31
anom_pattern = f->anom_pattern
anom_pattern!1 = "lat"
anom_pattern!2 = "lon"
anom_pattern&lat = ispan(-3,2,1)
anom_pattern&lon = ispan(-3,2,1)

anom_array = where(anom_array.eq.0, anom_array@_FillValue, anom_array)
print(num(.not.ismissing(anom_array(:,0))))
printVarSummary(anom_pattern)

ncases = max(number)  ; maximum of number is the number of cases
print(ncases)
delete(f)

; get shading interval
mean  = dim_avg_n(anom_array, 0)
print(mean)
std = dim_stddev_n(anom_array, 0)
printVarSummary(std)

upper = mean + 1.96 * std / sqrt(ncases)
lower = mean - 1.96 * std /sqrt(ncases)

conf = anom_array(0:1, :)
conf(0,:) = lower
conf(1,:) = upper

delete(number)
delete(upper)
delete(lower)
;------

f = addfile("composite_coldwake_series_daily_dayclm_cntl_spread_380-389.nc","r")
number = f->number
anom_array2 = f->anom_array  ; case, 31
anom_array2 = where(anom_array2.eq.0, anom_array@_FillValue, anom_array2)

ncases = max(number)  ; maximum of number is the number of cases
print(ncases)
delete(f)

; get shading interval
mean2  = dim_avg_n(anom_array2, 0)
std2 = dim_stddev_n(anom_array2, 0)
printVarSummary(std2)

upper = mean2 + 1.96 * std2 / sqrt(ncases)
lower = mean2 - 1.96 * std2 /sqrt(ncases)

conf2 = anom_array2(0:1, :)
conf2(0,:) = lower
conf2(1,:) = upper


;------------------------------------



    wks = gsn_open_wks("pdf","cold_wake_series_spread")             
    res = True
    res@vpWidthF =0.7
    res@vpHeightF = 0.5
    res@gsnDraw = False
    res@gsnFrame = False
    res@trXMinF  =-3
    res@trXMaxF = 27
    res@trYMinF = -1.2
    res@trYMaxF = 0.1
    res@xyLineColor = "Steelblue"
    res@xyLineThicknessF = 3.
    res@tmXMajorGrid = True
    res@tmYMajorGrid = True
    res@tmYMajorGridLineDashPattern = 1.
    res@tmXMajorGridLineDashPattern = 1.
    res@tmYMajorGridLineColor = "grey"
    res@tmXMajorGridLineColor = "grey"


    res@tiYAxisString = "SST anomalies (~S~o~N~C)"



    plot = new(2, graphic)
    res@tiXAxisString = "Days"
    res@tiMainString = "Composite cold wake (intense storms)"
    plot(1)  = gsn_csm_xy(wks,ispan(-3,27,1),mean,res)
    
    res@tiMainString = "Comoposite cold wake (all storms)"
    res@tiXAxisString = ""
    plot(0) =  gsn_csm_xy(wks,ispan(-3,27,1),mean2,res)
    res@trYMinF = -1.2
    res@trYMaxF = 0.1
    res@xyLineColor = -1
    res@gsnXYFillColors = "lightblue"
    res@gsnXYFillOpacities = 0.4
    plot1  = gsn_csm_xy (wks,ispan(-3, 27, 1),conf,res) ; create filled
    res@trYMinF = -1.2


    plot2  = gsn_csm_xy (wks,ispan(-3, 27, 1),conf2,res) ; create filled
    overlay(plot(0),plot2)
    overlay(plot(1),plot1)
    
resp = True
resp@amJust = "BottomRight"
resp@gsnPanelFigureStringsFontHeightF = 0.02
resp@gsnPanelFigureStrings = (/"a)", "b)"/)
resp@gsnPanelBottom = 0.05
 gsn_panel(wks, plot, (/2, 1/), resp)



end

   
