function vcf_display_earth(panelFile)
% VCF_DISPLAY_EARTH  Plot 1000 Genomes sample concentration by population code on a world map.
% No jitter. Marker size proportional to sample count. Color encodes super-population.
%
% Input
%   panelFile : tab-delimited file with columns: sample, pop, super_pop, gender
%
% Notes
%   - 1000 Genomes does not provide individual GPS coordinates. This plot is a visualization
%     of sampling populations, not exact personal locations.

T = readtable(panelFile,'FileType','text','Delimiter','\t');

sample = string(T.sample);
pop    = string(T.pop);
sp     = string(T.super_pop);

% ---- population code -> approximate sampling coordinates (city-level) ----
popCode = ["ACB","ASW","BEB","CDX","CEU","CHB","CHS","CLM","ESN","FIN","GBR","GIH","GWD","IBS","ITU","JPT","KHV","LWK","MSL","MXL","PEL","PJL","PUR","STU","TSI","YRI"];

lat = [ ...
  13.0975, ...  % ACB  Bridgetown, Barbados
  33.4484, ...  % ASW  Phoenix, AZ, USA
  23.8103, ...  % BEB  Dhaka, Bangladesh
  21.9710, ...  % CDX  Jinghong (Xishuangbanna), China
  40.7608, ...  % CEU  Salt Lake City, UT, USA
  39.9042, ...  % CHB  Beijing, China
  23.1291, ...  % CHS  Guangzhou, China (Southern Han proxy)
   6.2442, ...  % CLM  Medellín, Colombia
   6.3350, ...  % ESN  Benin City, Nigeria (proxy)
  60.1699, ...  % FIN  Helsinki, Finland
  51.5074, ...  % GBR  London, UK
  29.7604, ...  % GIH  Houston, TX, USA
  13.4549, ...  % GWD  Banjul, The Gambia
  39.4699, ...  % IBS  Valencia, Spain
  51.5074, ...  % ITU  London, UK (proxy)
  35.6762, ...  % JPT  Tokyo, Japan
  10.8231, ...  % KHV  Ho Chi Minh City, Vietnam
   0.6170, ...  % LWK  Webuye, Kenya (proxy)
   8.4657, ...  % MSL  Freetown, Sierra Leone (proxy)
  34.0522, ...  % MXL  Los Angeles, CA, USA
 -12.0464, ...  % PEL  Lima, Peru
  31.5204, ...  % PJL  Lahore, Pakistan
  18.4655, ...  % PUR  San Juan, Puerto Rico
  51.5074, ...  % STU  London, UK (proxy)
  43.7696, ...  % TSI  Florence, Italy (Tuscany)
   7.3775  ...  % YRI  Ibadan, Nigeria
];

lon = [ ...
  -59.6145, ... % ACB  Bridgetown
 -112.0740, ... % ASW  Phoenix
   90.4125, ... % BEB  Dhaka
  100.7600, ... % CDX  Jinghong
 -111.8910, ... % CEU  Salt Lake City
  116.4074, ... % CHB  Beijing
  113.2644, ... % CHS  Guangzhou
  -75.5812, ... % CLM  Medellín
    5.6275, ... % ESN  Benin City
   24.9384, ... % FIN  Helsinki
   -0.1278, ... % GBR  London
  -95.3698, ... % GIH  Houston
  -16.5790, ... % GWD  Banjul
   -0.3763, ... % IBS  Valencia
   -0.1278, ... % ITU  London
  139.6503, ... % JPT  Tokyo
  106.6297, ... % KHV  Ho Chi Minh City
   34.7710, ... % LWK  Webuye
  -13.2317, ... % MSL  Freetown
 -118.2437, ... % MXL  Los Angeles
  -77.0428, ... % PEL  Lima
   74.3587, ... % PJL  Lahore
  -66.1057, ... % PUR  San Juan
   -0.1278, ... % STU  London
   11.2558, ... % TSI  Florence
    3.8964  ... % YRI  Ibadan
];

Loc = table(popCode(:), lat(:), lon(:), 'VariableNames', {'pop','lat','lon'});

% ---- attach lat/lon to each subject by population code ----
% Use ismember to map each subject's pop to Loc
[tf, loc] = ismember(pop, Loc.pop);
lat0 = nan(size(pop));
lon0 = nan(size(pop));
lat0(tf) = Loc.lat(loc(tf));
lon0(tf) = Loc.lon(loc(tf));

% Remove subjects whose pop code is not in the lookup table (should be none for Phase 3)
keep = ~isnan(lat0) & ~isnan(lon0);
sample = sample(keep);
pop    = pop(keep);
sp     = sp(keep);
lat0   = lat0(keep);
lon0   = lon0(keep);

% ---- jitter: spread individuals within each population "cloud" ----
rng(1);
jscale = 10;%0.35;                          % jitter in degrees (tune)
latj = lat0 + jscale*(rand(size(lat0))-0.5);
lonj = lon0 + jscale*(rand(size(lon0))-0.5);

% ---- color by super_pop (identical RGB per group) ----
C = zeros(length(sp),3);
cAFR = [0.85 0.2 0.2];
cEUR = [0.2 0.4 0.9];
cEAS = [0.2 0.7 0.3];
cSAS = [0.9 0.6 0.2];
cAMR = [0.7 0.2 0.8];

C(sp=="AFR",:) = repmat(cAFR, sum(sp=="AFR"), 1);
C(sp=="EUR",:) = repmat(cEUR, sum(sp=="EUR"), 1);
C(sp=="EAS",:) = repmat(cEAS, sum(sp=="EAS"), 1);
C(sp=="SAS",:) = repmat(cSAS, sum(sp=="SAS"), 1);
C(sp=="AMR",:) = repmat(cAMR, sum(sp=="AMR"), 1);

% ---- plot ----
figure;
geobasemap landcover
geolimits([-60 80],[-180 180])
hold on

h = geoscatter(latj, lonj, 10, C, 'filled');
h.MarkerFaceAlpha = 0.65;

title('1000 Genomes: All Subjects (dots) Colored by super\_pop');

hold off



% Optional: show counts
tabulate(sp)

end