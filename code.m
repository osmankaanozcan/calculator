function axa()
    fig = uifigure('Name', 'Basic Calculator', 'Position', [100 100 850 650]);

    % NOTLAR ve TUŞLAR
    uilabel(fig, 'Position', [20 610 500 25], 'Text', '⚠️ NOT: Payda yoksa "1" bırakın. ☻.', ...
        'FontWeight', 'bold', 'FontColor', [0.7 0.2 0]);

    uilabel(fig, 'Position', [20 570 100 22], 'Text', 'PAY f(x):', 'FontWeight', 'bold');
    payEdit = uieditfield(fig, 'text', 'Position', [120 570 220 25], 'Value', 'x^2 - 1');

    uilabel(fig, 'Position', [20 535 100 22], 'Text', 'PAYDA g(x):', 'FontWeight', 'bold');
    paydaEdit = uieditfield(fig, 'text', 'Position', [120 535 220 25], 'Value', '1');

    uilabel(fig, 'Position', [20 500 100 22], 'Text', 'Kısayollar:', 'FontWeight', 'bold');
    uibutton(fig, 'Text', 'x²', 'Position', [120 500 45 22], 'ButtonPushedFcn', @(btn,event) ekle('^2'));
    uibutton(fig, 'Text', 'ln', 'Position', [170 500 45 22], 'ButtonPushedFcn', @(btn,event) ekle('log(')); 
    uibutton(fig, 'Text', 'π', 'Position', [220 500 45 22], 'ButtonPushedFcn', @(btn,event) ekle('pi'));
    uibutton(fig, 'Text', 'e', 'Position', [270 500 45 22], 'ButtonPushedFcn', @(btn,event) ekle('exp(x)'));
    
    function ekle(s)
        payEdit.Value = [payEdit.Value, s];
        focus(payEdit);
    end

    uilabel(fig, 'Position', [20 460 100 22], 'Text', 'İşlem Türü:');
    typeDrop = uidropdown(fig, 'Position', [120 460 220 22], 'Items', ...
        {'Sadece Grafik Çiz', 'Türev Al', 'Belirli İntegral', 'Belirsiz İntegral', 'Ters Fonksiyon', 'Polinom Kökleri', 'Polinom Bölmesi'});

    uilabel(fig, 'Position', [20 420 80 22], 'Text', 'Grafik Sınırı:');
    altEdit = uieditfield(fig, 'text', 'Position', [120 420 105 22], 'Value', '-5');
    ustEdit = uieditfield(fig, 'text', 'Position', [235 420 105 22], 'Value', '5');

    uibutton(fig, 'Position', [20 370 320 40], 'Text', 'HESAPLAMAYI BAŞLAT', ...
        'ButtonPushedFcn', @(btn,event) hesaplaMotoru(), 'BackgroundColor', [0 0.4 0.2], 'FontColor', 'w', 'FontWeight', 'bold');

    lblResult = uitextarea(fig, 'Position', [20 40 320 320], 'Editable', 'off', 'FontSize', 13, 'FontName', 'Consolas');

    ax = uiaxes(fig, 'Position', [370 40 450 580]);
    grid(ax, 'on');

    % HESAPLAMA KISMI
    function hesaplaMotoru()
        try
            x = sym('x');
            
            p_str = regexprep(strrep(payEdit.Value, 'ln', 'log'), '(\d)([a-zA-Z])', '$1*$2');
            h_str = regexprep(strrep(paydaEdit.Value, 'ln', 'log'), '(\d)([a-zA-Z])', '$1*$2');

            P = str2sym(p_str);
            H = str2sym(h_str);
            f = P / H; 

            cla(ax); hold(ax, 'on'); legend(ax, 'off');

            switch typeDrop.Value
                case 'Polinom Bölmesi'
                    [Q, R] = quorem(P, H, x);
                    lblResult.Value = ['İŞLEM: (Pay) / (Payda)', ...
                                       newline, '------------------', ...
                                       newline, 'BÖLÜM (Q):', newline, char(Q), ...
                                       newline, newline, 'KALAN (R):', newline, char(R)];
                    fplot(ax, Q, 'LineWidth', 2);
                    title(ax, 'Bölüm Fonksiyonu Grafiği');

                case 'Polinom Kökleri'
                    kokler = solve(P == 0, x);
                    lblResult.Value = ['Denklem: ', char(simplify(f)), ...
                                       newline, newline, 'Kökler (Payı Sıfır Yapanlar):', ...
                                       newline, char(kokler)];
                    fplot(ax, f);
                    num_kok = double(kokler(isreal(kokler)));
                    if ~isempty(num_kok)
                        plot(ax, num_kok, zeros(size(num_kok)), 'ro', 'MarkerFaceColor', 'r');
                    end

                case 'Türev Al'
                    df = diff(f, x);
                    lblResult.Value = ['Fonksiyon: ', char(f), ...
                                       newline, newline, 'Türevi:', newline, char(simplify(df))];
                    fplot(ax, f, 'b', 'DisplayName', 'f(x)');
                    fplot(ax, df, 'r--', 'DisplayName', "f'(x)");
                    legend(ax, 'show');

                case 'Belirsiz İntegral'
                    F = int(f, x);
                    lblResult.Value = ['İntegral:', newline, char(F), ' + C'];
                    fplot(ax, f);

                case 'Belirli İntegral'
                    a = double(str2sym(altEdit.Value));
                    b = double(str2sym(ustEdit.Value));
                    res = int(f, x, a, b);
                    lblResult.Value = ['Sonuç: ', char(res), newline, '≈ ', num2str(double(res))];
                    fplot(ax, f, [a-2, b+2]);
                    
                case 'Ters Fonksiyon'
                    f_inv = finverse(f, x);
                    lblResult.Value = ['Ters Fonksiyon:', newline, char(f_inv)];
                    fplot(ax, f, 'b'); fplot(ax, f_inv, 'r--');
                
                otherwise
                    fplot(ax, f);
            end
            hold(ax, 'off');
        catch ME
            lblResult.Value = ['Hata: ', ME.message];
        end
    end
end