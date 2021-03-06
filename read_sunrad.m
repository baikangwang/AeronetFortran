clear;
stats_aod=[];
stns_fn='Lasha';
fout=['H:\CIMEL_NETWORK\' stns_fn '\'];
mkdir(fout);
fpath=['H:\sunrad\OPT\' stns_fn '\'];
fname=dir([fpath '*' stns_fn '*.opt']);
for id=1:length(fname);
% for id=15:15;
    aod=[];
    alpha=[];
    file=[fpath fname(id).name];
    fid=fopen(file);
    tline=fgetl(fid);
    strwv=tline(regexp(tline,'\d'));
    for iw=1:length(strwv)/4;
        wv(iw)=str2num(strwv((iw-1)*4+1:iw*4))/1000;
    end;
    p440=find(abs(0.440-wv)<0.02);
    p675=find(abs(0.675-wv)<0.02);
    p870=find(abs(0.870-wv)<0.02);
    nobs=0;
    while(feof(fid)==0);
        nobs=nobs+1;
        tline=fgetl(fid);
        tline=tline(regexp(tline,'\d'));
        aod(nobs,3)=str2num(tline(1:2));        %日
        aod(nobs,2)=str2num(tline(3:4));        %月
        aod(nobs,1)=str2num(tline(5:6))+2000;   %年
        aod(nobs,4)=str2num(tline(7:8));        %时
        aod(nobs,5)=str2num(tline(9:10));       %分
        aod(nobs,6)=str2num(tline(11:12));      %秒
        for iw=1:length(wv);
            aod(nobs,iw+6)=str2num(tline((iw-1)*5+13:iw*5+12))/10000;%aod
        end;
%=========================================================        
%       to calculate Angstrom wavelength exponent
        alpha(nobs,1)=log(aod(nobs,p440+6)/aod(nobs,p675+6))/log(wv(p675)/wv(p440));
        alpha(nobs,2)=log(aod(nobs,p675+6)/aod(nobs,p870+6))/log(wv(p870)/wv(p675));
        alpha(nobs,3)=log(aod(nobs,p440+6)/aod(nobs,p870+6))/log(wv(p870)/wv(p440));
%       to calculate Angstrom wavelength exponent
%========================================================
        
    end;
    if(nobs>=3);
        stats_aod=[stats_aod;[aod,alpha]];
    end;
    if(nobs>=3);
        plot(aod(:,4)+aod(:,5)/60+aod(:,6)/3600,aod(:,7:end),'-*');hold on;
%         plot(aod(:,4)+aod(:,5)/60+aod(:,6)/3600,alpha,'-s');
        set(gca,'xminortick','on','yminortick','on');
        xlabel('Local Time');ylabel('Aerosol optical depth and Angstrom exponent');
        day=file(regexp(file,'\d'));
        eval(['print -dtiff ' fout 'fig_aeronet_aod_' day '.tiff']);
        close;
    end;
end;
%==================================================================
% to write the instantaneous aod and alpha
fid=fopen([fout 'stats_aod.dat'],'w');
fprintf(fid,'%s',['yyyy,mm,dd,hh,mm,ss,']);
for iw=1:length(wv);
    fprintf(fid,'%s',['aod' num2str((wv(iw)*1000)),',']);
end;
fprintf(fid,'%s',['AE440-675,','AE675-870,','AE440-870,']);
fprintf(fid,'\n');
for id=1:length(stats_aod(:,1));
    fprintf(fid,'%4i, %2i, %2i, %2i, %2i, %2i,',stats_aod(id,1:6));
    for iw=1:length(wv);
        fprintf(fid,'%7.4f,',stats_aod(id,6+iw));
    end;
    for ip=1:3;
        fprintf(fid,'%7.4f,',stats_aod(id,6+length(wv)+ip));
    end;
    fprintf(fid,'\n');
end;
fclose(fid);
%=====================================================================
%=====================================================================
%                   画图
linec=['-c';'-m';'-r';'-g';'-b';'-k';'-y'];
plot(datenum(stats_aod(:,1:6)),stats_aod(:,7:6+length(wv)));
datetick('x',12);hold on;
set(gca,'xlim',[datenum(stats_aod(1,1:6)) datenum(stats_aod(end,1:6))]);
set(gca,'xminortick','on','yminortick','on');
legend(num2str(wv'));
xlabel('Date (MMMYY)');ylabel('Aerosol optical depth');
eval(['print -depsc ' fout 'stats_aod.eps']);
close;
