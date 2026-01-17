%% FINANTIAL NETWORK DATA 
% between 2000-01-01 to 2025-12-31 stored as stocks.mat
% stocks is a 18-by-1 cell array
% Each cell stocks{k} is a table containing daily market data for one asset.
%
% Note: Not all assets have data back to 2000.
% Some started trading later (e.g., PLTR begins in 2020).
%
% Each stocks{k} table has the following columns (variables):
%   1) Date   : datetime, trading day 
%   2) Symbol : string, stocks symbol used in New York stock market 
%   3) Company: string, company name 
%   4) Open   : opening price of the trading day
%   5) High   : highest price reached during the trading day
%   6) Low    : lowest price reached during the trading day
%   7) Close  : closing price of the trading day
%   8) Volume : double, number of shares traded that day (daily volume)
%
%

load 'stocks.mat'  % TABLE data structure, can be imported/exported from/into Excel spreadsheet. 
  
%% MERGE ALL ASSETS INTO ONE TABLE (long-format)
T = vertcat(stocks{:});
% Now T contains ALL rows from ALL assets with columns:
% Date, Symbol, Company, Open, High, Low, Close, Volume

symbols   = unique(T.Symbol);
companies = unique(T.Company);

[symbols companies]  %18×2 string array

% "AAPL"     "Apple"
% "MSFT"     "Microsoft"
% "AMZN"     "Amazon"
% "NVDA"     "NVIDIA"
% "GOOGL"    "Alphabet"
% "TSLA"     "Tesla"
% "INTC"     "Intel"
% "CVX"      "Chevron"
% "XOM"      "Exxon Mobil"
% "JPM"      "JPMorgan Chase"
% "C"        "Citigroup"
% "PLTR"     "Palantir"
% "PG"       "Procter & Gamble"
% "KO"       "Coca-Cola"
% "JNJ"      "Johnson & Johnson"
% "COST"     "Costco"
% "UPS"      "UPS"
% "VOO"      "Vanguard S&P 500 ETF"

%% Let's cluster them into sectors -- Later we will study how to cluster (time series) data
% Platform & Software Infrastructure (AI / Cloud / Data Platforms)
% MSFT (Microsoft), GOOGL (Alphabet), PLTR (Palantir)
%
% IT Hardware & Semiconductors
% AAPL (Apple), NVDA (NVIDIA), INTC (Intel)
%
% Consumer Discretionary
% AMZN (Amazon), TSLA (Tesla)
%
% Consumer Staples (Defensive)
% PG (Procter & Gamble), KO (Coca-Cola), COST (Costco)
%
% Energy
% CVX (Chevron), XOM (Exxon Mobil)
%
% Banks
% JPM (JPMorgan Chase), C (Citigroup)
%
% Health Care
% JNJ (Johnson & Johnson)
%
% Transportation
% UPS (UPS)
%
% Broad Market ETF
% VOO (Vanguard S&P 500 ETF)

%% EXTRACT ONE COMPANY'S DATA (example: PLTR)
Tk = T(T.Symbol == "PLTR", :);

% 1320×8 table
% 
%        Date       Symbol     Company       Open      High      Low      Close       Volume  
%     __________    ______    __________    ______    ______    ______    ______    __________
% 
%     2020-09-30    "PLTR"    "Palantir"        10     11.42      9.11       9.5    3.3858e+08
%     2020-10-01    "PLTR"    "Palantir"      9.69      10.1      9.23      9.46     1.243e+08
%     2020-10-02    "PLTR"    "Palantir"      9.06      9.28      8.94       9.2    5.5018e+07
%     2020-10-05    "PLTR"    "Palantir"      9.43      9.49      8.92      9.03    3.6317e+07
%     2020-10-06    "PLTR"    "Palantir"      9.04     10.18       8.9       9.9    9.0864e+07
% 
%         :           :           :           :         :         :         :           :     
% 
%     2025-12-24    "PLTR"    "Palantir"    193.16    195.17    192.83    194.17     1.171e+07
%     2025-12-26    "PLTR"    "Palantir"    195.01    196.35    188.62    188.71    2.6262e+07
%     2025-12-29    "PLTR"    "Palantir"    186.85     187.2    183.64    184.18    2.8242e+07
%     2025-12-30    "PLTR"    "Palantir"    184.35    184.73     180.7    180.84    2.3336e+07
%     2025-12-31    "PLTR"    "Palantir"    181.13    181.53    177.25    177.75    2.2997e+07
 

%% PLOT A SINGLE PRICE SERIES (example: closing price)
figure; plot(Tk.Date, Tk.Close)
% X-axis: Date (trading days), Y-axis: Close (end-of-day price)

% Moving average
Tk.MA20 = movmean(Tk.Close, 20);  % window length (e.g., 20 trading days - one month)
Tk.MA60 = movmean(Tk.Close, 60);  % window length (e.g., 20 trading days - one month)

figure;
plot(Tk.Date, Tk.Close); hold on;
plot(Tk.Date, Tk.MA20, 'LineWidth', 1);
plot(Tk.Date, Tk.MA60, 'LineWidth', 2);


% LIMITATIONS OF SLIDING-WINDOW (MOVING AVERAGE)
%
% 1) Boundary effects:
%    At the beginning and end of the time series, the window is truncated,
%    leading to biased or less stable estimates.
%
% 2) Arbitrary window length:
%    The choice of 20 or 60 days is heuristic.
%    Different window sizes can produce qualitatively different conclusions.
%
% 3) Time–frequency tradeoff:
%    Moving averages smooth noise but also smear rapid changes,
%    delaying detection of regime shifts and turning points.
%
% 4) Nonstationarity:
%    Financial time series are nonstationary.
%    A fixed window assumes local stationarity, which may not hold.
%
% 5) Induces artificial oscillations:
%    A periodic moving window is equivalent to multiplying the signal by a
%    rectangular window in time. The sharp cutoff at the window boundaries
%    introduces discontinuities that cause ringing artifacts (Gibbs phenomenon)
%    and spectral leakage, potentially creating false periodic-looking
%    patterns that are not present in the original data.
%
% We will study how to remedy these issues and develop a new averaging
% operation for time series data. 


%% MATLAB LAPLACE TRANSFORM: INPUT f(t) (LEFT) vs OUTPUT F(s) (RIGHT)
% Top row: simple example
% Bottom row: more complex example
%
% Each row shows the time-domain input f(t) on the left and its Laplace
% transform F(s)=L{f}(s) on the right computed by MATLAB laplace().

syms t s

tvals = linspace(0,10,500);
svals = linspace(0.05,10,500);     % avoid s=0 singularity

figure;

%% ===== TOP: f(t)=exp(-2t) =====
f1  = exp(-2*t);
F1  = laplace(f1, t, s);           % MATLAB symbolic Laplace transform

f1_t = double(subs(f1, t, tvals));
F1_s = double(subs(F1, s, svals));

subplot(2,2,1)
plot(tvals, f1_t, 'LineWidth',2)
title('Input: $f(t)=e^{-2t}$','Interpreter','latex')
xlabel('$t$','Interpreter','latex')
ylabel('$f(t)$','Interpreter','latex')
grid on

subplot(2,2,2)
plot(svals, F1_s, 'LineWidth',2)
title('Output: $F(s)=\mathcal{L}\{f(t)\}(s)$','Interpreter','latex')
xlabel('$s$','Interpreter','latex')
ylabel('$F(s)$','Interpreter','latex')
grid on


%% ===== BOTTOM: f(t)=t^2 e^{-t}\sin(2\pi t) =====
f2  = t^2*exp(-t)*sin(2*pi*t);
F2  = laplace(f2, t, s);           % MATLAB symbolic Laplace transform

f2_t = double(subs(f2, t, tvals));
F2_s = double(subs(F2, s, svals));

subplot(2,2,3)
plot(tvals, f2_t, 'LineWidth',2)
title('Input: $f(t)=t^2 e^{-t}\sin(2\pi t)$','Interpreter','latex')
xlabel('$t$','Interpreter','latex')
ylabel('$f(t)$','Interpreter','latex')
grid on

subplot(2,2,4)
plot(svals, F2_s, 'LineWidth',2)
title('Output: $F(s)=\mathcal{L}\{f(t)\}(s)$','Interpreter','latex')
xlabel('$s$','Interpreter','latex')
ylabel('$F(s)$','Interpreter','latex')
grid on


%% POSSIBLE PROJECT TOPIC 1/20
% TIME-VARYING VECTOR FIELD FROM TWO STOCKS (CVX vs XOM)
% Chevron (CVX) and Exxon Mobil (XOM) are two major oil & gas majors. 
% Their revenues, costs, and valuations are driven by the same global forces: 
% crude oil prices, refining margins, OPEC policy, and geopolitical supply shocks. 
% As a result, their daily and monthly returns tend to move together very closely, 
% often with correlations exceeding those of most other stock pairs.
% We treat (x(t),y(t)) = (return_CVX(t), return_XOM(t)) as a time trajectory,
% and define a vector at each time by the increment:
%   v(t) = (dx(t), dy(t)) = (x(t+1)-x(t), y(t+1)-y(t)).
% Then we smooth the dynamic vector fields using the Laplace Transform.


% 1) Align by common trading dates (keep Close only)
S = innerjoin( ...
    T(T.Symbol=="CVX", ["Date","Close"]), ...
    T(T.Symbol=="XOM", ["Date","Close"]), ...
    'Keys',"Date");

S.Properties.VariableNames = ["Date","CVX","XOM"];

% 2) Raw vector field (tail = price, vector = next-day increment)
% Price increase/decrease
P  = [S.CVX, S.XOM];                % N x 2
dP = diff(P,1,1);                   % (N-1) x 2

figure;
quiver(P(1:end-1,1), P(1:end-1,2), dP(:,1), dP(:,2), 0); hold on
xlabel('CVX'); ylabel('XOM'); grid on

% 3) OU / Laplace mean smoothing
lambda = 1/20;                      % ~20-day time constant
Ps  = LaplaceT_OUmean(P, lambda);   % N x 2
dPs = diff(Ps,1,1);                 % (N-1) x 2

quiver(Ps(1:end-1,1), Ps(1:end-1,2), dPs(:,1), dPs(:,2), 0, 'LineWidth', 2);
legend('Raw','OU mean'); legend boxoff



