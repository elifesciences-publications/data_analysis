function y = doFilter(x)
%DOFILTER Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.1 and the DSP System Toolbox 9.3.
% Generated on: 19-Sep-2017 15:29:36

%#codegen

% To generate C/C++ code from this function use the codegen command.
% Type 'help codegen' for more information.

persistent Hd;

if isempty(Hd)

    % The following code was used to design the filter coefficients:
    %
    % N    = 100;  % Order
    % F3dB = 4;    % 3-dB Frequency
    % Fs   = 30;   % Sampling Frequency
    %
    % h = fdesign.lowpass('n,f3db', N, F3dB, Fs);
    %
    % Hd = design(h, 'butter', ...
    %     'SystemObject', true);

    Hd = dsp.BiquadFilter( ...
        'Structure', 'Direct form II', ...
        'SOSMatrix', [1 2 1 1 -1.3228201819761 0.976923741650914; 1 2 1 1 ...
        -1.29299736379002 0.932354239220937; 1 2 1 1 -1.2645308796524 ...
        0.889811746220183; 1 2 1 1 -1.23735665178505 0.849200499911748; 1 2 1 1 ...
        -1.21141402428863 0.810429851476466; 1 2 1 1 -1.18664561346486 ...
        0.773414042322942; 1 2 1 1 -1.16299715811208 0.73807198035769; 1 2 1 1 ...
        -1.14041737140893 0.704327018628884; 1 2 1 1 -1.11885779563639 ...
        0.672106738211796; 1 2 1 1 -1.09827266068775 0.641342736755245; 1 2 1 1 ...
        -1.07861874707014 0.611970423740666; 1 2 1 1 -1.05985525390096 ...
        0.58392882320579; 1 2 1 1 -1.04194367223965 0.557160384441967; 1 2 1 1 ...
        -1.02484766396457 0.531610800978569; 1 2 1 1 -1.00853294630027 ...
        0.507228838011621; 1 2 1 1 -0.992967182017294 0.483966168309988; 1 2 1 1 ...
        -0.978119875262024 0.461777216535591; 1 2 1 1 -0.963962272924149 ...
        0.440619011839328; 1 2 1 1 -0.950467271411163 0.420451048537784; 1 2 1 1 ...
        -0.937609328671585 0.401235154633982; 1 2 1 1 -0.925364381288568 ...
        0.382935367915737; 1 2 1 1 -0.913709766452277 0.365517819345196; 1 2 1 1 ...
        -0.902624148611261 0.348950623441038; 1 2 1 1 -0.892087450599196 ...
        0.333203775349001; 1 2 1 1 -0.882080789032779 0.318249054295559; 1 2 1 1 ...
        -0.872586413778629 0.304059933122617; 1 2 1 1 -0.863587651291117 ...
        0.290611493607229; 1 2 1 1 -0.855068851628668 0.277880347278704; 1 2 1 1 ...
        -0.847015338962869 0.26584456145563; 1 2 1 1 -0.839413365402333 ...
        0.254483590236719; 1 2 1 1 -0.832250067961452 0.243778210191617; 1 2 1 1 ...
        -0.825513428512766 0.233710460510662; 1 2 1 1 -0.819192236570454 ...
        0.224263587385684; 1 2 1 1 -0.813276054761346 0.215421992407237; 1 2 1 1 ...
        -0.807755186848702 0.20717118477689; 1 2 1 1 -0.802620648182803 ...
        0.199497737146331; 1 2 1 1 -0.797864138461041 0.192389244907955; 1 2 1 1 ...
        -0.793478016688644 0.185834288774256; 1 2 1 1 -0.789455278239425 ...
        0.17982240049566; 1 2 1 1 -0.785789533923995 0.174344031578451; 1 2 1 1 ...
        -0.782474990980638 0.169390524876084; 1 2 1 1 -0.779506435911637 ...
        0.16495408893848; 1 2 1 1 -0.776879219095169 0.161027775014859; 1 2 1 1 ...
        -0.774589241109993 0.157605456616308; 1 2 1 1 -0.772632940717067 ...
        0.154681811554589; 1 2 1 1 -0.771007284448941 0.152252306383735; 1 2 1 1 ...
        -0.769709757764327 0.150313183180756; 1 2 1 1 -0.768738357731606 ...
        0.148861448611316; 1 2 1 1 -0.768091587211303 0.14789486523558; 1 2 1 1 ...
        -0.767768450513688 0.147411945018592], ...
        'ScaleValues', [0.163525889918704; 0.15983921885773; ...
        0.156320216641945; 0.152960962031674; 0.14975395679696; ...
        0.146692107214519; 0.143768705561402; 0.140977411804988; ...
        0.138312235643851; 0.135767519016875; 0.133337919167632; ...
        0.131018392326207; 0.12880417805058; 0.126690784253501; ...
        0.124673972927837; 0.122749746573174; 0.120914335318392; ...
        0.119164184728795; 0.117495944281655; 0.115906456490599; ...
        0.114392746656792; 0.11295201322323; 0.111581618707444; ...
        0.110279081187451; 0.109042066315695; 0.107868379835997; ...
        0.106755960579028; 0.105702873912509; 0.10470730562319; ...
        0.103767556208596; 0.102882035557541; 0.102049257999474; ...
        0.101267837703808; 0.100536484411473; 0.0998539994820471; ...
        0.099219272240882; 0.0986312766117285; 0.0980890680214032; ...
        0.0975917805640588; 0.097138624413614; 0.0967288834738616; ...
        0.0963619132567109; 0.0960371389799226; 0.0957540538765787; ...
        0.0955122177093805; 0.0953112554836983; 0.0951508563541071; ...
        0.0950307727199274; 0.0949508195060691; 0.0949108736262262; 1]);
end

y = step(Hd,x);
delay = mean(grpdelay(Hd));
y(1:delay) = [];
