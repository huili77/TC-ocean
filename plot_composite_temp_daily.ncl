load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"    
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/popRemap.ncl" 
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "/projects/sciteam/bbdt/ncl_functions/surfaceWindCorrFactor.ncl"
load "/projects/sciteam/bbdt/ncl_functions/getTrajectoriesGeneric.ncl"
load "/projects/sciteam/bbdt/ncl_functions/mask_tc.ncl"


;************************************************
begin


; we could start by lookinga at global average, then individual basin
; seperate into different TC categories according to maximum wind speed


anom_array= new((/30,51, 20, 20/),"float")   
anom_array!0 = "time"
anom_array&time = ispan(0,29,1)   ; -1 to 20 days
anom_array!1 = "z_t"
anom_array = 0.

number = anom_array



cutwind=0.0
factor = surfaceWindCorrFactor(-1,-1,"log")

f = addfile("trajectory_file_330-450.nc","r")
traj_data  = f->traj_data
printVarSummary(traj_data)


lon = traj_data(:,1,:)
lat = traj_data(:,2,:)
wind = traj_data(:,3,:) * factor
pres = traj_data(:,4,:)/100.
yyyy=  traj_data(:,6,:)
mm= traj_data(:,7,:)
dd= traj_data(:,8,:)
hh= traj_data(:,9,:)

doy = day_of_year(toint(yyyy),toint(mm),toint(dd))
YYYYMMDDHH=1000000*toint(yyyy)+10000*toint(mm)+100*toint(dd)+toint(hh)
YYYYDDD =  1000 * toint(yyyy) + doy
delete(f)

ndims = dimsizes(lon)
nstorms = ndims(0)
ntimes = ndims(1)


  case = "b.e13.B1850C5CN.ne30_g16.005ax_exact_tcdaily"
  fils = systemfunc("ls ~/scratch/archive/"+case+"/ocn/hist/regrid_"+case+".pop.h.nday1.03{5..6}*.nc")
  nfils = dimsizes(fils)
  print(nfils)

  f = addfiles(fils, "r")
  ListSetType(f, "cat")
  time = f[:]->time
  ntime = dimsizes(time)
  temp = f[:]->TEMP(:,:,50:130,:)
  printVarSummary(temp)

  minlat = min(temp&lat)
  maxlat = max(temp&lat)
  minlon = min(temp&lon)
  maxlon = max(temp&lon)
  print(minlat)
  print(maxlat)

   TIME    = cd_calendar(time, 0)          ; type float 
   year    = toint( TIME(:,0) )
   month   = toint( TIME(:,1) )
   day     = toint( TIME(:,2) ) 
   ddd     = day_of_year(year, month, day) 
   yyyyddd = year*1000 + ddd                     ; needed for input

   temp&time = yyyyddd

;  temp_clm = clmDayTLLL(temp,yyyyddd)
 ; printVarSummary(temp_clm)
;  fout = addfile(case+".pop.h.temp.dayclm.0330-0359_new.nc","r")
;  fout->TEMP = temp_clm

  
  setfileoption("nc","Format","LargeFile")
 fc = addfile(case+".pop.h.temp.dayclm.0350-0399_regrid.nc","r")
 temp_clm = fc->TEMP

  temp_anom = calcDayAnomTLLL(temp, yyyyddd, temp_clm)
  temp_anom&time = yyyyddd
  printVarSummary(temp_anom)

  delete(fils)
  delete(f)
  delete(temp)
  delete(year)
  delete(ddd)
  delete(month)
  delete(day)


;--------------------
;-------------------------------
; now loop through TCs
 
inds = ind(yyyy(:,0).eq.350)   ; find index in trajectory file
indstart = inds(0)
delete(inds)

inds = ind(yyyy(:,0).eq.370)   ; find index in trajectory file
indsend = inds(0)
delete(inds)

do ii = indstart,indsend-1
   inds = ind(yyyy(ii,:).ne.340.and.hh(ii,:).eq.0.and..not.ismissing(doy(ii,:)).and..not.ismissing(wind(ii,:)))

   if (.not.ismissing(inds(0))) then
   len = dimsizes(inds)

   mlat = lat(ii,inds)
   mlon = lon(ii,inds)
   mtime = YYYYDDD(ii,inds)    
   mday = doy(ii,inds)  ; day of year
   mwind = wind(ii,inds)


   do jj = 0, len-1               ; loop through TC days
     tlat=mlat(jj)+10                    ; including ramping area
     blat=mlat(jj)-10
     tlon=mlon(jj)+10
     blon=mlon(jj)-10

    ; now find the time in sst anom. To avoid end of year, we use index rather than named dimension
    shf_ind = ind(yyyyddd.eq.mtime(jj))    ; daily sst index

     if (.not.ismissing(shf_ind).and.(shf_ind+30.le.ntime-1).and.(shf_ind+1.ge.0))

       if (tlat.le.maxlat.and.blat.ge.minlat.and.tlon.le.maxlon.and.blon.ge.minlon) 
;*****
; now we align the track date and the model output date
    shf_ind =  shf_ind + 1
;*********

      domain=temp_anom({time|yyyyddd(shf_ind):yyyyddd(shf_ind+29)},{z_t|:},{lat|blat:tlat},{lon|blon:tlon}) 

      domain_size = dimsizes(domain)
      printVarSummary(domain)
      
;      pre_avg = dim_avg_n_Wrap(domain(0:2,:,:),0) ; -7 to -5 day

      anom = domain

    if ((domain_size(2).eq.20).and.(domain_size(3).eq.20))

       if (.not.all(ismissing(anom))) 
         number_temp = where(ismissing(anom), 0, 1)
         anom = where(ismissing(anom), 0, anom)

         anom_array = anom_array + anom
         number = number + number_temp
         
         delete(number_temp)
       end if
    end if
 

    delete(anom)
;    delete(pre_avg)
    delete(domain)
    delete(domain_size)
     end if                 ; end if shf_ind+10 exceeds bound

     end if
     delete(shf_ind)

   end do                   ; end looping through TC days

    delete(mlat)
    delete(mlon)
    delete(mtime)
    delete(mwind)
    delete(mday)

    end if
    delete(inds)
    end do                ; end loopiong thorugh tc cases


     
   number = where(number.eq.0, 1, number)
   anom_array = anom_array/number ;the composite array we need


 fout = addfile("./composite_temp_series_tcdaily_4day.350-360_20deg.nc","c")
 fout->temp_array = anom_array
 fout->number = number


end





