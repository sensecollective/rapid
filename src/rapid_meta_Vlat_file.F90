!*******************************************************************************
!Subroutine - rapid_meta_Vlat_file
!*******************************************************************************
subroutine rapid_meta_Vlat_file(Vlat_file) 

!Purpose:
!Read metadata for Vlat_file from Fortran/netCDF.
!Author: 
!Cedric H. David, 2016-2018.


!*******************************************************************************
!Global variables
!*******************************************************************************
use netcdf
use rapid_var, only :                                                          &
                   rank,IS_nc_status,IS_nc_id_fil_Vlat,                        &
                   IS_nc_id_var_time,IS_nc_id_var_time_bnds,IS_nc_id_var_crs,  &
                   IS_nc_id_var_lon,IS_nc_id_var_lat,IS_nc_id_var_sVlat,       &
                   IS_riv_tot,IS_riv_bas,IS_time,JS_time,ZS_TauR,              &
                   YV_title,YV_institution,YV_comment,                         &
                   YV_time_units,YV_crs_sma,YV_crs_iflat,                      &
                   ZV_riv_tot_lon,ZV_riv_tot_lat,IV_time,IM_time_bnds,         &
                   ZV_riv_tot_sQlat,ZS_TauR

implicit none


!*******************************************************************************
!Includes
!*******************************************************************************


!*******************************************************************************
!Intent (in/out), and local variables 
!*******************************************************************************
character(len=*), intent(in):: Vlat_file


!*******************************************************************************
!Read global attributes
!*******************************************************************************
if (rank==0) then 
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "title", YV_title)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "institution", YV_institution)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,NF90_GLOBAL,                  \
                  "comment", YV_comment)
end if


!*******************************************************************************
!Read variable attributes
!*******************************************************************************
if (rank==0) then 
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_time,            \
                  "units", YV_time_units)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_crs,             \
                  "semi_major_axis", YV_crs_sma)
     IS_nc_status=NF90_GET_ATT(IS_nc_id_fil_Vlat,IS_nc_id_var_crs,             \
                  "inverse_flattening", YV_crs_iflat)
end if


!*******************************************************************************
!Read space and time variable values
!*******************************************************************************
if (rank==0) then 
     if (IS_nc_id_var_lon>=0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_lon,             \
                               ZV_riv_tot_lon,(/1/),(/IS_riv_tot/))
     end if
     if (IS_nc_id_var_lat>=0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_lat,             \
                               ZV_riv_tot_lat,(/1/),(/IS_riv_tot/))
     end if
     if (IS_nc_id_var_time>=0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_time,            \
                               IV_time,(/1/),(/IS_time/))
     end if
     if (IS_nc_id_var_time_bnds>=0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_time_bnds,       \
                               IM_time_bnds,(/1,1/),(/2,IS_time/))
     end if
end if


!*******************************************************************************
!Read uncertainty quantification inputs, convert from volume to flow
!*******************************************************************************
if (rank==0) then 
     if (IS_nc_id_var_sVlat>=0) then
     IS_nc_status=NF90_GET_VAR(IS_nc_id_fil_Vlat,IS_nc_id_var_sVlat,           \
                               ZV_riv_tot_sQlat,(/1/),(/IS_riv_tot/))
     ZV_riv_tot_sQlat=ZV_riv_tot_sQlat/ZS_TauR
     end if
end if


!*******************************************************************************
!Check temporal consistency if metadata present
!*******************************************************************************
if (IV_time(1)/=-9999) then
     do JS_time=1,IS_time-1
     if (IV_time(JS_time+1)-IV_time(JS_time)/=int(ZS_TauR)) then
     !Checking that interval between values of the time variable is ZS_TauR
          print '(a53)','Inconsistent time intervals in namelist and Vlat_file'
          stop 99
     end if
     end do
end if

if (IM_time_bnds(1,1)/=-9999) then
     do JS_time=1,IS_time-1
     if (IM_time_bnds(1,JS_time+1)-IM_time_bnds(1,JS_time)/=int(ZS_TauR)) then
     !Checking that interval between values of the time_bnd variable is ZS_TauR
          print '(a53)','Inconsistent time intervals in namelist and Vlat_file'
          stop 99
     end if
     end do
     do JS_time=1,IS_time
     if (IM_time_bnds(2,JS_time)-IM_time_bnds(1,JS_time)/=int(ZS_TauR)) then
     !Checking that interval for each value of the time_bnd variable is ZS_TauR
          print '(a53)','Inconsistent time intervals in namelist and Vlat_file'
          stop 99
     end if
     end do
end if


!*******************************************************************************
!End subroutine 
!*******************************************************************************
end subroutine rapid_meta_Vlat_file
