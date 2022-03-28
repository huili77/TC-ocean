; check TC-induced cold wake
;cold wake is compared to pre-storm condition, and daily climatology  in control


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 
load "/projects/sciteam/bbdt/ncl_functions/surfaceWindCorrFactor.ncl"
load "/projects/sciteam/bbdt/ncl_functions/getTrajectoriesGeneric.ncl"
load "/projects/sciteam/bbdt/ncl_functions/mask_tc.ncl"

;========================================================
begin
;files = systemfunc("ls coldwake_map_3{7,8,9}*.nc")
;print(files)
;f = addfiles(files,"r")
;ListSetType(f, "join")
;map = f[:]->map
;map_mean = dim_avg_n_Wrap(map,0)

f = addfile("coldwake_map_370-399_prestorm.nc","r")
map_mean = f->map
printVarSummary(map_mean)
delete(f)


;  now read in fully coupled high-res model cold wake
;f = addfile("/projects/sciteam/bbdt/diagnostics/cold_wake_map_hybrid_42-71.nc","r")
f = addfile("/projects/sciteam/bbdt/diagnostics/cold_wake_map_hybrid_42-71_prestorm.nc","r")
map_hybrid = f->map



; ---------------------------
    wks = gsn_open_wks("pdf","cold_wake_30yearr_highlow_2panel")              ; send graphics to PNG file
    gsn_define_colormap(wks, "BlueWhiteOrangeRed")
    res = True
   res@gsnDraw=False
   res@gsnFrame=False
    res@gsnLeftString  = " "

   res@cnFillDrawOrder             = "PreDraw"
   res@cnFillOn                    = True
   res@cnLinesOn                   = False
   res@cnLevelSelectionMode = "ManualLevels"
   res@cnMinLevelValF       = -1.5
   res@cnMaxLevelValF       = 1.5 
   res@cnLevelSpacingF      = 0.05

   res@mpOutlineOn            = True
   res@mpGeophysicalLineColor = "Gray21"    ; map outline color
   res@mpGridAndLimbOn        = False        ; turn on lat/lon lines
  res@mpGridLineColor        = "black"    ; line color
  res@mpGridAndLimbDrawOrder = "PreDraw"   ; draw lines first, so
 
   res@mpPerimOn              = False
   res@mpProjection = "Robinson"
   
   res@mpMaxLatF                   = 60           ; choose a different subregion
   res@mpMinLatF                   = -60
;   res@mpMaxLonF                   = 360
;   res@mpMinLonF                   = 0
   res@mpCenterLonF                = 180
   res@gsnAddCyclic  = True
   res@gsnSpreadColors = True
   res@gsnSpreadColorStart = 20
   res@gsnSpreadColorEnd = -19


;  resp@lbLabelStride = 1
  res@pmLabelBarWidthF = 0.4
  res@pmLabelBarHeightF = 0.06
  res@lbLabelFontHeightF = 0.013


  plot = new(2, graphic)

  res@tiMainString = "Annual mean SST cold wake (high-res control)"
  plot(0) = gsn_csm_contour_map(wks, map_hybrid,res)  
  res@tiMainString = "Annual mean SST cold wake (low-res TC)"
  plot(1)  = gsn_csm_contour_map(wks,map_mean,res)   

  resp = True
  resp@gsnPanelFigureStrings= (/"a)","b)"/) ; add strings to panel
  resp@gsnPanelFigureStringsFontHeightF = 0.02
  resp@amJust   = "TopLeft"
  gsn_panel(wks,plot, (/2, 1/), resp)
  

end


