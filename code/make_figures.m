function make_figures()
% Figures of the IN718 powder-reuse article, generated from the data files in
% ../data/derived and ../data/05_xrd/raw. Each figure is exported as vector PDF (submission)
% and as 600 dpi PNG (placement in the Word file). Multi-panel figures are laid out
% left to right at double-column width; single-panel figures use single-column width.
%
%   Fig02_campaign      jobs, reuse cycle, layers and build duration (Table 2)
%   Fig03_workflow      experimental workflow
%   Fig06_size_shape    size and shape distributions (particle annotations)
%   Fig07_maps          diameter-circularity maps by morphology class
%   Fig08_morphology    morphology class composition
%   Fig10_eds           EDS metallic proportions and remainder (Table 5)
%   Fig11_xrd           XRD patterns of powders and bulk samples (raw scans)
%   Fig12_xrd_shift     XRD peak shifts and displacement-corrected lattice parameter
%   Fig13_flow          funnel flow times by zone and job
%   Fig14_mpm_maps      exported melt-pool monitoring maps on one colour scale
%   Fig15_mpm           melt-pool emission read from the exported monitoring maps
%   Fig16_hardness      Vickers microhardness per reuse level

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
outdir = fullfile(root, 'figures');                     % figure output folder
S = style();
fig_campaign(S, outdir);
fig_workflow(S, outdir);
fig_size_shape(S, outdir);
fig_maps(S, outdir);
fig_morphology(S, outdir);
fig_eds(S, outdir);
fig_xrd(S, outdir);
fig_xrd_shift(S, outdir);
fig_mpm(S, outdir);
fig_mpm_maps(S, outdir);
fig_flow(S, outdir);
fig_hardness(S, outdir);
end

% ========================================================================= style
function S = style()
S.font   = 'Times New Roman';
S.fs     = 9;            % pt, all text
S.w1     = 8.5;          % cm, single-column width
S.w2     = 17.0;         % cm, double-column width (panels side by side)
S.h      = 5.8;          % cm, height of one panel row
S.lw     = 1.0;          % data line width
S.axlw   = 0.75;         % axes line width
S.ms     = 5;            % marker size
S.blue   = [0 114 178]/255;   S.orange = [230 159 0]/255;   S.green = [0 158 115]/255;
S.verm   = [213 94 0]/255;    S.purple = [204 121 167]/255; S.sky   = [86 180 233]/255;
S.grey   = [0.45 0.45 0.45];  S.black  = [0 0 0];
% powder conditions (ordinal): light to dark blue
S.cond   = {'Virgin', 'Zone 1, reuse 0', 'Zone 4, reuse 5', 'Zone 4, reuse 6'};
S.condc  = [0.62 0.79 0.93; 0.33 0.56 0.80; 0.06 0.25 0.55; 0.00 0.08 0.25];
S.condls = {'-', '--', '-.', ':'};
% morphology classes (categorical)
S.cls    = {'Spherical particle', 'Agglomerated, sintered or fused particles', ...
            'Particles with a satellite', 'Deformed particle', 'Elongated particle'};
S.clsl   = {'Spherical', 'Agglomerated, sintered or fused', 'With satellite', 'Deformed', 'Elongated'};
S.clsc   = [S.blue; S.verm; S.green; S.orange; S.purple];
end

function f = newfig(S, w, h)
f = figure('Units', 'centimeters', 'Position', [2 2 w h], 'PaperUnits', 'centimeters', ...
    'PaperSize', [w h], 'Color', 'w', 'Visible', 'off');
set(f, 'DefaultAxesFontName', S.font, 'DefaultAxesFontSize', S.fs, ...
    'DefaultTextFontName', S.font, 'DefaultTextFontSize', S.fs, ...
    'DefaultLegendFontName', S.font, 'DefaultLegendFontSize', S.fs, ...
    'DefaultColorbarFontName', S.font, 'DefaultColorbarFontSize', S.fs);
end

function styleax(ax, S)
set(ax, 'FontName', S.font, 'FontSize', S.fs, 'LineWidth', S.axlw, 'Box', 'on', ...
    'TickDir', 'in', 'TickLength', [0.015 0.015], 'XColor', S.black, 'YColor', S.black, 'Layer', 'top');
end

function panel(ax, S, lbl)
% label placed a fixed 0.9 cm left of and 0.15 cm above the axes corner, in every figure
drawnow;
u = ax.Units; ax.Units = 'centimeters'; p = ax.Position; ax.Units = u;
text(ax, -0.9 / p(3), 1 + 0.15 / p(4), lbl, 'Units', 'normalized', 'FontName', S.font, ...
    'FontSize', S.fs, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
end

function savefig_(f, outdir, name)
exportgraphics(f, fullfile(outdir, [name '.pdf']), 'ContentType', 'vector');
exportgraphics(f, fullfile(outdir, [name '.png']), 'Resolution', 900);
close(f);
end

function T = morph_data(outdir)
T = readtable(fullfile(fileparts(outdir), 'data', 'derived', 'morphology_particles.csv'), 'TextType', 'string');
end

% ========================================================================= Fig 2
function fig_campaign(S, outdir)
job    = 1:13;
reuse  = [0 0 0 0 0 1 2 3 4 5 6 7 8];
layers = [3269 3269 300 3368 5371 5371 371 2627 2592 NaN 834 127 2248];
dur    = [1*24+13+50/60, 1*24+13+50/60, 3+31/60, 23+1/60, 3*24+1+29/60, 2*24+18+23/60, ...
          13+8/60, 1*24+7+44/60, 1*24+9+9/60, NaN, NaN, 13+49/60, 1*24+0+35/60];
cmap = parula(9);
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 2, 'TileSpacing', 'compact', 'Padding', 'loose');
Y = {layers, dur}; yl = {'Layers', 'Build duration (h)'}; ym = [6000 80];
for k = 1:2
    ax = nexttile(t); hold(ax, 'on');
    for j = job
        if ~isnan(Y{k}(j))
            bar(ax, j, Y{k}(j), 0.7, 'FaceColor', cmap(reuse(j)+1,:), 'EdgeColor', S.black, 'LineWidth', 0.5);
        else
            text(ax, j, 0.02*ym(k), 'n/r', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontName', S.font, 'FontSize', S.fs - 1);
        end
    end
    xlim(ax, [0.3 13.7]); ylim(ax, [0 ym(k)]); set(ax, 'XTick', job, 'XTickLabelRotation', 0);
    xlabel(ax, 'Job'); ylabel(ax, yl{k}); styleax(ax, S);
    colormap(ax, cmap); clim(ax, [-0.5 8.5]);
    axs(k) = ax; %#ok<AGROW>
end
cb = colorbar(axs(2)); cb.Layout.Tile = 'east'; cb.Ticks = 0:8; cb.Label.String = 'Reuse cycle';
cb.LineWidth = S.axlw; cb.FontName = S.font; cb.FontSize = S.fs;
panel(axs(1), S, '(a)'); panel(axs(2), S, '(b)');
savefig_(f, outdir, 'Fig02_campaign');
end

% ========================================================================= Fig 3
function fig_workflow(S, outdir)
W = S.w2; H = 7.6;
f = newfig(S, W, H);
ax = axes(f, 'Position', [0 0 1 1]); hold(ax, 'on'); axis(ax, [0 W 0 H]); axis(ax, 'off');
edge = [0.30 0.30 0.30];
cA = [0.87 0.92 0.97]; cZ = [0.99 0.93 0.85]; cZ4 = [0.97 0.83 0.72]; cZ5 = [0.93 0.88 0.95];
cC = [0.88 0.95 0.90]; cD = [0.93 0.93 0.93];
wbox(ax, S, [0.3 6.0 4.0 1.3], cA, edge, {'Gas-atomised IN718 powder', ['15–45 ' char(181) 'm, 100 kg batch']});
wbox(ax, S, [0.3 2.9 4.0 2.5], cA, edge, {'LPBF job, SLM 280', '13 jobs, reuse cycles 0–8', ...
    'Yb fibre laser, 1070 nm', '7 mm stripes, argon', 'Melt-pool monitoring'});
wbox(ax, S, [0.3 0.3 4.0 1.6], cA, edge, {'Ultrasonic sieving, PSM 100', '7 kHz, argon', 'Sieved powder reloaded'});
% build chamber group with Zones 1-4
rectangle(ax, 'Position', [5.0 2.55 4.9 4.85], 'Curvature', 0.04, 'EdgeColor', edge, 'LineStyle', '--', 'LineWidth', 0.6);
text(ax, 7.45, 7.15, 'Build chamber', 'HorizontalAlignment', 'center', 'FontName', S.font, 'FontSize', S.fs);
zl = {'Zone 1, recoater', 'Zone 2, chamber mid', 'Zone 3, chamber left', 'Zone 4, chamber extreme left'};
zy = [5.95 4.85 3.75 2.75];
for k = 1:4
    fc = cZ; if k == 4, fc = cZ4; end
    wbox(ax, S, [5.2 zy(k) 4.5 0.8], fc, edge, zl(k));
end
text(ax, 7.45, 2.45, 'gas flow towards Zone 4', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', ...
    'FontName', S.font, 'FontSize', S.fs - 1, 'Color', S.grey);
wbox(ax, S, [5.2 0.4 4.5 1.1], cZ5, edge, {'Zone 5, sieve reject'});
wbox(ax, S, [10.6 1.3 3.4 5.4], cC, edge, {'Characterisation', 'SEM and particle', 'classification', ...
    'EDS (Ni, Cr, Fe, C)', ['XRD (Cu K' char(945) ')'], 'Hall, Carney and', 'Gustavsson flow', 'Vickers hardness', 'of printed parts'});
wbox(ax, S, [14.6 2.6 2.25 2.8], cD, edge, {'Comparison by', 'zone and cycle', ' ', 'Location-aware', 'recovery', '(proposed)'});
% arrows
warrow(ax, [2.3 6.0], [2.3 5.4], edge);                         % powder -> LPBF
warrow(ax, [1.5 2.9], [1.5 1.9], edge);                         % LPBF -> sieving
text(ax, 1.6, 2.4, 'recovered', 'FontName', S.font, 'FontSize', S.fs - 1, 'HorizontalAlignment', 'left');
warrow(ax, [3.2 1.9], [3.2 2.9], edge);                         % sieving -> LPBF (next job)
text(ax, 3.3, 2.4, 'cycle + 1', 'FontName', S.font, 'FontSize', S.fs - 1, 'HorizontalAlignment', 'left');
warrow(ax, [4.3 4.2], [5.0 4.2], edge);                         % LPBF -> chamber sampling
warrow(ax, [4.3 0.95], [5.2 0.95], edge);                       % sieving -> reject
text(ax, 4.75, 1.08, 'reject', 'FontName', S.font, 'FontSize', S.fs - 1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
warrow(ax, [9.9 4.9], [10.6 4.9], edge);                        % zones -> characterisation
warrow(ax, [9.7 0.95], [10.6 1.6], edge);                       % reject -> characterisation
warrow(ax, [14.0 4.0], [14.6 4.0], edge);                       % characterisation -> comparison
savefig_(f, outdir, 'Fig03_workflow');
end

function wbox(ax, S, pos, fc, ec, lines)
rectangle(ax, 'Position', pos, 'Curvature', 0.08, 'FaceColor', fc, 'EdgeColor', ec, 'LineWidth', 0.6);
n = numel(lines); lh = 0.42;
y0 = pos(2) + pos(4)/2 + (n - 1) * lh / 2;
for k = 1:n
    text(ax, pos(1) + pos(3)/2, y0 - (k - 1) * lh, lines{k}, 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', 'FontName', S.font, 'FontSize', S.fs, 'Interpreter', 'none');
end
end

function warrow(ax, p1, p2, c)
plot(ax, [p1(1) p2(1)], [p1(2) p2(2)], '-', 'Color', c, 'LineWidth', 0.8);
v = p2 - p1; v = v / norm(v); n = [-v(2) v(1)]; L = 0.22; Wd = 0.09;
tip = p2; base = p2 - L * v;
patch(ax, [tip(1) base(1)+Wd*n(1) base(1)-Wd*n(1)], [tip(2) base(2)+Wd*n(2) base(2)-Wd*n(2)], c, 'EdgeColor', c);
end

% ========================================================================= Fig 6
function fig_size_shape(S, outdir)
T = morph_data(outdir);
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 3, 'TileSpacing', 'compact', 'Padding', 'loose');
vars = {'eq_diameter_um', 'circularity', 'elongation'};
xl = {['Equivalent diameter (' char(181) 'm)'], 'Circularity', 'Elongation'};
xr = {[0 90], [0.2 1.0], [1 3]};
for k = 1:3
    ax = nexttile(t); hold(ax, 'on'); h = gobjects(4, 1);
    for c = 1:4
        v = sort(T.(vars{k})(T.condition == S.cond{c}));
        yv = (1:numel(v))' / numel(v) * 100;
        h(c) = stairs(ax, [v(1); v], [0; yv], S.condls{c}, 'Color', S.condc(c,:), 'LineWidth', S.lw);
    end
    xlim(ax, xr{k}); ylim(ax, [0 100]); xlabel(ax, xl{k}, 'Interpreter', 'none');
    if k == 1, ylabel(ax, 'Cumulative fraction (%)'); end
    if k == 3
        n = arrayfun(@(c) sum(T.condition == S.cond{c}), 1:4);
        lab = arrayfun(@(c) sprintf('%s (n = %d)', S.cond{c}, n(c)), 1:4, 'UniformOutput', false);
        lg = legend(ax, h, lab, 'Location', 'southeast', 'Box', 'off'); lg.ItemTokenSize = [16 8];
    end
    styleax(ax, S); axs(k) = ax; %#ok<AGROW>
end
panel(axs(1), S, '(a)'); panel(axs(2), S, '(b)'); panel(axs(3), S, '(c)');
savefig_(f, outdir, 'Fig06_size_shape');
end

% ========================================================================= Fig 7
function fig_maps(S, outdir)
T = morph_data(outdir);
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 4, 'TileSpacing', 'compact', 'Padding', 'loose');
lbl = {'(a)', '(b)', '(c)', '(d)'};
for c = 1:4
    ax = nexttile(t); hold(ax, 'on');
    sub = T(T.condition == S.cond{c}, :);
    h = gobjects(5, 1);
    for k = 1:5
        m = sub.class == S.cls{k};
        h(k) = scatter(ax, sub.eq_diameter_um(m), sub.circularity(m), 7, S.clsc(k,:), 'filled', ...
            'MarkerFaceAlpha', 0.75, 'MarkerEdgeColor', 'none');
    end
    xlim(ax, [0 90]); ylim(ax, [0.2 1.05]); xlabel(ax, ['Diameter (' char(181) 'm)'], 'Interpreter', 'none');
    if c == 1, ylabel(ax, 'Circularity'); else, set(ax, 'YTickLabel', []); end
    text(ax, 0.97, 0.98, S.cond{c}, 'Units', 'normalized', 'HorizontalAlignment', 'right', ...
        'VerticalAlignment', 'top', 'FontName', S.font, 'FontSize', S.fs);
    styleax(ax, S); axs(c) = ax; %#ok<AGROW>
end
lg = legend(axs(1), h, S.clsl, 'Orientation', 'horizontal', 'Box', 'off');
lg.Layout.Tile = 'south'; lg.ItemTokenSize = [8 8];
for c = 1:4, panel(axs(c), S, lbl{c}); end
savefig_(f, outdir, 'Fig07_maps');
end

% ========================================================================= Fig 8
function fig_morphology(S, outdir)
T = morph_data(outdir);
P = zeros(4, 5); n = zeros(1, 4);
for c = 1:4
    lab = T.class(T.condition == S.cond{c}); n(c) = numel(lab);
    for k = 1:5, P(c, k) = 100 * sum(lab == S.cls{k}) / n(c); end
end
f = newfig(S, S.w1, S.h + 1.2);
ax = axes(f); hold(ax, 'on');
order = 4:-1:1;                                   % virgin at the top
b = barh(ax, 1:4, P(order, :), 0.65, 'stacked', 'EdgeColor', S.black, 'LineWidth', 0.4);
for k = 1:5, b(k).FaceColor = S.clsc(k,:); end
for r = 1:4
    x0 = 0;
    for k = 1:5
        v = P(order(r), k);
        if v >= 6
            tc = [1 1 1]; if k == 4, tc = S.black; end
            text(ax, x0 + v/2, r, sprintf('%.0f', v), 'HorizontalAlignment', 'center', ...
                'FontName', S.font, 'FontSize', S.fs - 1, 'Color', tc);
        end
        x0 = x0 + v;
    end
end
ylab = arrayfun(@(c) sprintf('%s (n = %d)', S.cond{c}, n(c)), order, 'UniformOutput', false);
set(ax, 'YTick', 1:4, 'YTickLabel', ylab); xlim(ax, [0 100]); ylim(ax, [0.4 4.6]);
xlabel(ax, 'Fraction of particles (%)');
lg = legend(ax, b, S.clsl, 'Location', 'southoutside', 'NumColumns', 2, 'Box', 'off');
lg.ItemTokenSize = [8 8];
styleax(ax, S);
savefig_(f, outdir, 'Fig08_morphology');
end

% ========================================================================= Fig 10
function fig_eds(S, outdir)
%        reuse zone   Ni    Cr    Fe    C      (Table 5, wt%, normalised by the EDS software)
T = [    2    1     35.5  13.3  12.1  35.0
         2    2     37.8  14.1  12.4  33.9
         2    3     38.3  14.8  13.2  26.4
         2    4     44.5  16.8  15.3  14.6
         2    5     11.5   4.3   4.2  14.9
         3    4     22.9   9.3   7.9  18.9
         4    3     43.5  16.5  14.6  18.7
         5    1     34.9  12.9  12.8  38.9
         7    1     34.8  13.7  11.6  34.5
         7    2     31.5  12.7  10.9  39.9
         7    3      8.4   3.2   3.0  26.2
         7    4      7.3   2.9   2.4  31.8 ];
metal = sum(T(:,3:5), 2); frac = 100 * T(:,3:5) ./ metal; rem = 100 - metal - T(:,6);
nominal = [52.5 19.0 18.5]; nominal = 100 * nominal / sum(nominal);
labels = arrayfun(@(r, z) sprintf('R%d-Z%d', r, z), T(:,1), T(:,2), 'UniformOutput', false);
f = newfig(S, S.w2, S.h + 0.6);
t = tiledlayout(f, 1, 2, 'TileSpacing', 'loose', 'Padding', 'loose');
ax1 = nexttile(t); hold(ax1, 'on'); x = 1:size(T,1);
mk = {'o', 's', '^'}; cl = [S.blue; S.verm; S.green]; nm = {'Ni', 'Cr', 'Fe'}; h = gobjects(3,1);
for e = 1:3
    yline(ax1, nominal(e), '--', 'Color', cl(e,:), 'LineWidth', 0.75);
    h(e) = plot(ax1, x, frac(:,e), mk{e}, 'Color', cl(e,:), 'MarkerFaceColor', cl(e,:), 'MarkerSize', S.ms);
end
ylabel(ax1, 'Fraction of Ni + Cr + Fe (wt%)'); xlim(ax1, [0.4 numel(x)+0.6]); ylim(ax1, [0 70]);
set(ax1, 'XTick', x, 'XTickLabel', labels, 'XTickLabelRotation', 45);
legend(ax1, h, nm, 'Location', 'east', 'Box', 'off'); styleax(ax1, S);
ax2 = nexttile(t); cyc = [2 3 4 5 7]; zon = 1:5; M = nan(5, 5);
for i = 1:size(T,1), M(T(i,2), cyc == T(i,1)) = rem(i); end
im = imagesc(ax2, M, 'AlphaData', ~isnan(M)); hold(ax2, 'on');
for r = 1:5
    for c = 1:5
        if isnan(M(r,c))
            patch(ax2, c + [-0.5 0.5 0.5 -0.5], r + [-0.5 -0.5 0.5 0.5], [0.93 0.93 0.93], 'EdgeColor', 'none');
            text(ax2, c, r, 'n/s', 'HorizontalAlignment', 'center', 'FontName', S.font, 'FontSize', S.fs - 1, 'Color', S.grey);
        end
    end
end
uistack(im, 'top');
for r = 1:5
    for c = 1:5
        if ~isnan(M(r,c))
            tc = S.black; if M(r,c) > 35, tc = [1 1 1]; end
            text(ax2, c, r, sprintf('%.1f', M(r,c)), 'HorizontalAlignment', 'center', 'FontName', S.font, ...
                'FontSize', S.fs - 1, 'Color', tc);
        end
    end
end
n = 256; colormap(ax2, [linspace(1,0.60,n)', linspace(1,0.10,n)', linspace(1,0.10,n)']); clim(ax2, [0 70]);
cb = colorbar(ax2); cb.Label.String = 'Remainder (wt%)'; cb.LineWidth = S.axlw; cb.FontName = S.font; cb.FontSize = S.fs;
set(ax2, 'XTick', 1:5, 'XTickLabel', string(cyc), 'YTick', zon, 'YTickLabel', compose('Zone %d', zon), 'YDir', 'reverse');
xlabel(ax2, 'Reuse cycle'); axis(ax2, 'tight'); styleax(ax2, S);
panel(ax1, S, '(a)'); panel(ax2, S, '(b)');
savefig_(f, outdir, 'Fig10_eds');
end

% ========================================================================= Fig 11
function fig_xrd(S, outdir)
xdir = fullfile(fileparts(outdir), 'data', '05_xrd', 'raw');
jobs = [6 7 8 10 11 12 13 14 15];
extra = containers.Map({'10', '11', '15'}, {36.78, [63.28 76.38 80.73], [36.75 63.38 76.50 80.71]});
gam = [43.6 50.8 74.6]; gl = {'111', '200', '220'};
f = newfig(S, S.w1 + 1.0, 11.0);
ax1 = axes(f); hold(ax1, 'on'); step = 1.15;
for i = 1:numel(jobs)
    [x, y] = xrdread(fullfile(xdir, sprintf('job_%d.csv', jobs(i)))); off = (i - 1) * step;
    plot(ax1, x, y + off, '-', 'Color', S.black, 'LineWidth', 0.5);
    text(ax1, 21, off + 0.3, sprintf('Job %d', jobs(i)), 'FontName', S.font, 'FontSize', S.fs - 1, 'VerticalAlignment', 'bottom');
    key = sprintf('%d', jobs(i));
    if isKey(extra, key)
        for p = extra(key)
            m = abs(x - p) < 0.3;
            text(ax1, p, max(y(m)) + off + 0.05, '*', 'FontName', S.font, 'FontSize', S.fs, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
        end
    end
end
ytop = numel(jobs) * step + 0.4; xrdmarks(ax1, S, gam, gl, ytop, true);
xlim(ax1, [20 90]); ylim(ax1, [-0.2 ytop + 0.6]); set(ax1, 'YTick', []);
xlabel(ax1, ['2' char(952) ' (' char(176) ')'], 'Interpreter', 'none'); ylabel(ax1, 'Normalised intensity (offset)'); styleax(ax1, S);
savefig_(f, outdir, 'Fig11_xrd');
end

function xrdmarks(ax, S, gam, gl, ytop, hashmark)
for k = 1:3
    xline(ax, gam(k), ':', 'Color', S.grey, 'LineWidth', 0.6);
    text(ax, gam(k), ytop, gl{k}, 'FontName', S.font, 'FontSize', S.fs - 1, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
if hashmark
    text(ax, 89.4, ytop, '#', 'FontName', S.font, 'FontSize', S.fs - 1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end
end

function [x, y] = xrdread(file)
% background-subtracted intensity normalised to the gamma(111) peak height
d = readmatrix(file, 'NumHeaderLines', 2); x = d(:,1); I = d(:,2);
m = x >= 20; x = x(m); I = I(m);
bkg = median(I(x > 55 & x < 70)); p111 = max(I(x > 41.5 & x < 44.5));
y = (I - bkg) / (p111 - bkg);
end

% ========================================================================= Fig 12
function fig_xrd_shift(S, outdir)
P = readtable(fullfile(fileparts(outdir), 'data', 'derived', 'xrd_gamma_peaks.csv'), 'TextType', 'string');
F = readtable(fullfile(fileparts(outdir), 'data', 'derived', 'xrd_displacement_fit.csv'), 'TextType', 'string');
lam = (2*1.540593 + 1.544414) / 3;
aref = F.lattice_parameter_A(F.scan == "job 6");
hk = [111 200 220]; hs = [3 4 8];
jobs = [6 7 8 10 11 12 13 14 15];
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 2, 'TileSpacing', 'loose', 'Padding', 'loose');
% (a) shift divided by cos(theta): constant across reflections for a specimen-height error alone
ax1 = nexttile(t); hold(ax1, 'on');
cm = lines(numel(jobs)); mk = {'o', 's', '^', 'd', 'v', '>', '<', 'p', 'h'}; h = gobjects(numel(jobs), 1);
for j = 1:numel(jobs)
    sc = sprintf('job %d', jobs(j)); y = zeros(1,3);
    for k = 1:3
        tt = P.two_theta_deg(P.scan == sc & P.hkl == hk(k));
        tc = 2 * asind(lam * sqrt(hs(k)) / (2 * aref));
        y(k) = (tt - tc) / cosd(tc / 2);
    end
    h(j) = plot(ax1, 1:3, y, ['-' mk{j}], 'Color', cm(j,:), 'MarkerFaceColor', cm(j,:), 'MarkerSize', S.ms - 1, 'LineWidth', 0.8);
end
yline(ax1, 0, ':', 'Color', S.grey);
set(ax1, 'XTick', 1:3, 'XTickLabel', {'(111)', '(200)', '(220)'}); xlim(ax1, [0.7 3.3]); ylim(ax1, [-1.7 0.5]);
xlabel(ax1, 'Reflection');
ylabel(ax1, [char(916) '2' char(952) ' / cos ' char(952) ' (' char(176) ')'], 'Interpreter', 'none');
legend(ax1, h, compose('Job %d', jobs), 'Location', 'eastoutside', 'Box', 'off');
styleax(ax1, S);
% (b) lattice parameter where one specimen height reproduces all three reflections
ax2 = nexttile(t); hold(ax2, 'on');
names = compose("job %d", jobs);
xt = compose("Job %d", jobs);
for i = 1:numel(names)
    r = F(F.scan == names(i), :);
    if r.rms_residual_deg < 0.02
        plot(ax2, i, r.lattice_parameter_A, 'o', 'Color', S.blue, 'MarkerFaceColor', S.blue, 'MarkerSize', S.ms);
    else
        text(ax2, i, 3.557, 'n/d', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
            'FontName', S.font, 'FontSize', S.fs - 1, 'Rotation', 90);
    end
end
xlim(ax2, [0.3 numel(names) + 0.7]); ylim(ax2, [3.55 3.63]);
set(ax2, 'XTick', 1:numel(names), 'XTickLabel', xt, 'XTickLabelRotation', 45);
ylabel(ax2, ['Lattice parameter (' char(197) ')'], 'Interpreter', 'none');
styleax(ax2, S);
panel(ax1, S, '(a)'); panel(ax2, S, '(b)');
savefig_(f, outdir, 'Fig12_xrd_shift');
end

% ========================================================================= Fig 13
function fig_flow(S, outdir)
T = readtable(fullfile(fileparts(outdir), 'data', 'derived', 'flow_times.csv'), 'TextType', 'string');
% values from 'flow rate measurement.xlsx'; its "Job 6" occasion is reuse 1 (machine and table numbering agree for job 6)
methods = ["Hall", "Carney", "Gustavsson"]; jobs = ["Reuse 1", "Reuse 4", "Reuse 5", "Reuse 8"];
jc = [S.blue; S.orange; S.green; S.verm];
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 3, 'TileSpacing', 'compact', 'Padding', 'loose');
for k = 1:3
    ax = nexttile(t); hold(ax, 'on');
    M = nan(5, 4);
    for j = 1:4
        r = T(T.method == methods(k) & T.job == jobs(j), :);
        M(r.zone, j) = r.flow_time_s;
    end
    b = bar(ax, 1:5, M, 0.8, 'grouped', 'EdgeColor', S.black, 'LineWidth', 0.4);
    for j = 1:4, b(j).FaceColor = jc(j,:); end
    xlim(ax, [0.4 5.6]); set(ax, 'XTick', 1:5, 'XTickLabelRotation', 0); xlabel(ax, 'Zone');
    ylim(ax, [0 ceil(max(M(:)) * 1.2)]);
    text(ax, 0.04, 0.96, methods(k), 'Units', 'normalized', 'FontName', S.font, 'FontSize', S.fs, 'VerticalAlignment', 'top');
    if k == 1, ylabel(ax, 'Flow time (s)'); end
    styleax(ax, S); axs(k) = ax; %#ok<AGROW>
end
lg = legend(axs(3), b, jobs, 'Orientation', 'horizontal', 'Box', 'off'); lg.Layout.Tile = 'south'; lg.ItemTokenSize = [10 8];
panel(axs(1), S, '(a)'); panel(axs(2), S, '(b)'); panel(axs(3), S, '(c)');
savefig_(f, outdir, 'Fig13_flow');
end

% ========================================================================= Fig 14
function fig_mpm_maps(S, outdir)
mdir = fullfile(fileparts(outdir), 'data', '07_melt_pool_monitoring', 'cropped_maps');
cyc = [0 1 7 8]; lbl = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)'};
f = newfig(S, S.w2, 9.0);
t = tiledlayout(f, 2, 4, 'TileSpacing', 'compact', 'Padding', 'loose');
k = 0;
for ch = 1:2
    for i = 1:4
        k = k + 1; ax = nexttile(t);
        im = imread(fullfile(mdir, sprintf('mpm_r%d_ch%d.png', cyc(i), ch)));
        [h, w, ~] = size(im);
        image(ax, im); axis(ax, 'image'); set(ax, 'XTick', [], 'YTick', [], 'Box', 'on', 'LineWidth', S.axlw);
        if ch == 1
            text(ax, w / 2, -0.02 * h, sprintf('Reuse %d', cyc(i)), 'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', 'FontName', S.font, 'FontSize', S.fs);
        end
        text(ax, 0.03 * w, 0.03 * h, lbl{k}, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', ...
            'FontName', S.font, 'FontSize', S.fs, 'BackgroundColor', 'w', 'Margin', 1);
        if i == 1, ylabel(ax, sprintf('Channel %d', ch), 'FontName', S.font, 'FontSize', S.fs); end
        axs(k) = ax; %#ok<AGROW>
    end
end
colormap(f, jet(256)); clim(axs(end), [0 2500]);
cb = colorbar(axs(end)); cb.Layout.Tile = 'east'; cb.Label.String = 'Emission (a.u.)';
cb.LineWidth = S.axlw; cb.FontName = S.font; cb.FontSize = S.fs; cb.Ticks = 0:500:2500;
savefig_(f, outdir, 'Fig14_mpm_maps');
end

% ========================================================================= Fig 15
function fig_mpm(S, outdir)
M = readtable(fullfile(fileparts(outdir), 'data', 'derived', 'mpm_emission_stats.csv'));
cyc = [0 1 7 8];
f = newfig(S, S.w2, S.h);
t = tiledlayout(f, 1, 2, 'TileSpacing', 'compact', 'Padding', 'loose');
for ch = 1:2
    ax = nexttile(t); hold(ax, 'on');
    for i = 1:numel(cyc)
        r = M(M.reuse_cycle == cyc(i) & M.channel == ch, :);
        x = i; w = 0.28;
        plot(ax, [x x], [r.p05 r.p25], '-', 'Color', S.black, 'LineWidth', 0.6);
        plot(ax, [x x], [r.p75 r.p95], '-', 'Color', S.black, 'LineWidth', 0.6);
        plot(ax, x + [-w w]/2, [r.p05 r.p05], '-', 'Color', S.black, 'LineWidth', 0.6);
        plot(ax, x + [-w w]/2, [r.p95 r.p95], '-', 'Color', S.black, 'LineWidth', 0.6);
        patch(ax, x + [-w w w -w], [r.p25 r.p25 r.p75 r.p75], S.sky, 'EdgeColor', S.black, 'LineWidth', 0.6);
        plot(ax, x + [-w w], [r.p50 r.p50], '-', 'Color', S.black, 'LineWidth', 1.0);
        plot(ax, x, r.mean, 'o', 'Color', S.black, 'MarkerFaceColor', 'w', 'MarkerSize', S.ms - 1);
    end
    set(ax, 'XTick', 1:numel(cyc), 'XTickLabel', string(cyc)); xlim(ax, [0.4 numel(cyc) + 0.6]); ylim(ax, [500 2200]);
    xlabel(ax, 'Reuse cycle');
    if ch == 1, ylabel(ax, 'Emission (a.u.)'); end
    text(ax, 0.03, 0.95, sprintf('Channel %d', ch), 'Units', 'normalized', 'FontName', S.font, 'FontSize', S.fs, ...
        'VerticalAlignment', 'top');
    styleax(ax, S); axs(ch) = ax; %#ok<AGROW>
end
panel(axs(1), S, '(a)'); panel(axs(2), S, '(b)');
savefig_(f, outdir, 'Fig15_mpm');
end

% ========================================================================= Fig 16
function fig_hardness(S, outdir)
% one part per reuse level, two parts (machine Jobs 1 and 3) at reuse 0
r  = [0 0 1 4 7 8]; hv = [313 324 319 276 265 257];
rc = [0 1 4 7 8];   hm = [318.5 319 276 265 257];      % mean per cycle
f = newfig(S, S.w1, S.h);
ax = axes(f); hold(ax, 'on');
plot(ax, rc, hm, '-', 'Color', S.grey, 'LineWidth', 0.8);
plot(ax, r, hv, 'o', 'Color', S.blue, 'MarkerFaceColor', S.blue, 'MarkerSize', S.ms);
dy = [-5 4 4 4 4 4]; va = {'top', 'bottom', 'bottom', 'bottom', 'bottom', 'bottom'};
for i = 1:numel(r)
    text(ax, r(i) + 0.15, hv(i) + dy(i), sprintf('%d', hv(i)), 'FontName', S.font, 'FontSize', S.fs - 1, ...
        'VerticalAlignment', va{i});
end
xlabel(ax, 'Reuse cycle'); ylabel(ax, 'Microhardness (HV)');
xlim(ax, [-0.5 9.3]); ylim(ax, [240 340]); set(ax, 'XTick', 0:8); styleax(ax, S);
savefig_(f, outdir, 'Fig16_hardness');
end
