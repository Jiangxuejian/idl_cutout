pro cutout
scale=0.34
Num = 517          ; 展源总数目
files=dialog_pickfile(file='E:\deepsurvey\*.*',/multiple_file)     ;文件所在目录
;fin='E:\deep survey\';
nfiles = n_elements(files)

openw,count_lun,'E:\deepsurvey\count.dat',/get_lun
openr,reg_file_lun,'E:\deepsurvey\reg_file.dat',/get_lun   ;RegionFile所在目录
source = dblarr(3,Num)    ;ra,dec,Num
readf,reg_file_lun,source
;print,source[*,0]
free_lun,reg_file_lun

for j=0,nfiles-1 do begin
fits_open,files[j],fcb
fits_read,fcb,image,header
fits_close,fcb

nx=fcb.axis[0]-1
ny=fcb.axis[1]-1

;XYAD  - Use FITS header to convert pixel (X,Y) to celestial(RA, Dec) coordinates
XYAD,header,0,0,x0,y0
XYAD,header,nx,ny,x1,y1

ra0=x0<x1          ;   < : Minimum operator.
ra1=x0>x1          ;   > : Maximum operator.
dec0=y0<y1
dec1=y0>y1
;print,header
;print,x0,y0,x1,y1
;print,ra0,ra1,dec0,dec1     ;218.95685       219.35051       35.195739       35.645068
;getxs,ra0,ra1,dec0,dec1,source,N


for i=0,Num-1 do begin
  ra = source[0,i]
  dec= source[1,i]
  if ((ra LE ra1) && (ra GE ra0) && (dec LE dec1) && (dec GE dec0)) then begin

  pixelcat=100
  ;要截取的像素尺寸

  ;fix(source[2,i]/scale)*3
  ;print,ra,dec
  ADXY, header, ra,dec, x,y

  x1=x-pixelcat > 0
  x2=x+pixelcat < nx-1
  y1=y-pixelcat > 0
  y2=y+pixelcat < ny-1
  ;print,x,x0,x1,y0,y1
  data=image[x1:x2,y1:y2]

  ;fout=string(byte(j/10+48))
  ;fout=fout+string(byte(j-j/10*10+48))

  ;输出文件
  fout = 'E:\deep survey\Output\G'+string(source[2,i])+'.fits'
  ;string(source[1,i])+ string(source[0,i])+'.fits'
  fits_write,fout,data,header
  printf,count_lun,source[*,i]
  endif
endfor
endfor
free_lun,count_lun

end
