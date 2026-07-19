%%

function MagicBallGui
   %  Create and then hide the GUI as it is being constructed.
   f = figure('Visible','off','Position',[360,500,500,300], 'Color',[0.8,0.8,0.8]);
   
   %  Construct the components.
   %creates a button with the Magic 8 Ball image
   h_image = imread('Magic8Ball.jpg');
      h_image_sm =imresize(h_image, [200 200]);
   hbutton_image = uicontrol('Style','pushbutton','Position',[50,60,200+10,200+10], ...
       'Cdata', h_image_sm,'Callback',@hbutton_image_Callback);    
  
   %Label  
   htext1 = uicontrol('Style','text', 'FontSize',12, 'BackgroundColor',[0.8,0.8,0.8], ...
       'Position',[280,260, 133, 20],'String','Ask your question');
   %Edit box where the user can type a question
   huitext = uicontrol('Style','edit','Position',[280,230,200,25], ...
                     'BackgroundColor', 'white', 'FontSize',12);   
      
   %The ANSWER from the magic ball   
   htext2 = uicontrol('Style','text','Position',[280,200,75,20], ...
           'String','Answer', 'FontSize',12,'BackgroundColor',[0.8,0.8,0.8]); 
   htext3 = uicontrol('Style','text','Position', [280,170,150,25], ...
            'BackgroundColor', 'white', 'String','', ...
            'ForegroundColor','Red','FontSize',12);   
   
   %button to CLEAR everything 
   hbutton_clear = uicontrol('Style','pushbutton',...
          'Position',[280,100,50,25],'String','Clear', 'FontSize',12,...
          'BackgroundColor',[0.6,0.6,0.6], 'Callback',@hbutton_clear_Callback);
        
   % Assign the GUI a name to appear in the window title.
   set(f,'Name','Magic Ball GUI')
   % Move the GUI to the center of the screen.
   movegui(f,'center')
   % Make the GUI visible.
   set(f,'Visible','on');
   
   function hbutton_image_Callback(~,~)             
      Answers={'It is certain', ... 
          'Ask again later', 'Very doubtful', 'Signs point to yes', ...
          'Yes', 'Without a doubt.', 'Better Not Tell You Now',...
          'My sources say no.', 'As I see it, yes.', 'You may rely on it.',...
          'Concentrate and ask again.', 'Outlook not so good.', ...
          'It is decidedly so.', 'Cannot predict now.', 'Most likely.', ...
          'My reply is no.','Don''t count on it.'};      
      set(htext3,'Visible','on','String', Answers{randi([1,17])});   
   end
 
   function hbutton_clear_Callback(~,~)               
      set(huitext,'String', '');
      set(htext3,'String', '');
   end
end 

