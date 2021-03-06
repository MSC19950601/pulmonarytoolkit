classdef MimPluginLabelSlider < GemLabelSlider
    % MimPluginLabelSlider. Part of the gui for the TD MIM Toolkit.
    %
    %     This class is used internally within the TD MIM Toolkit to help
    %     build the user interface.
    %
    %     MimPluginLabelSlider is used to build a slider control which interacts
    %     with the MIM GUI
    %
    %
    %     Licence
    %     -------
    %     Part of the TD MIM Toolkit. https://github.com/tomdoel
    %     Author: Tom Doel, Copyright Tom Doel 2014.  www.tomdoel.com
    %     Distributed under the MIT licence. Please see website for details.
    %
    
    properties (Access = private)
        GuiApp
        Tool
        FixToInteger = true
    end
    
    methods
        function obj = MimPluginLabelSlider(parent, tool, icon, gui_app)
            obj = obj@GemLabelSlider(parent, tool.ButtonText, tool.ToolTip, class(tool));
            obj.GuiApp = gui_app;
            obj.Tool = tool;
            
            [value_instance_handle, value_property_name, limits_instance_handle, limits_property_name] = tool.GetHandleAndProperty(gui_app);
            value = value_instance_handle.(value_property_name);
            
            if ~isempty(limits_property_name)
                limits = limits_instance_handle.(limits_property_name);
                if ~isempty(limits)
                    min_slider = limits(1);
                    max_slider = limits(2);
                else
                    min_slider = tool.MinValue;
                    max_slider = tool.MaxValue;
                end
            else
                min_slider = tool.MinValue;
                max_slider = tool.MaxValue;
            end
            
            obj.Slider.SetSliderLimits(min_slider, max_slider);
            obj.Slider.SetSliderSteps([tool.SmallStep, tool.LargeStep]);
            obj.Slider.SetSliderValue(value);
            
            obj.EditBoxPosition = tool.EditBoxPosition;
            obj.EditBoxWidth = tool.EditBoxWidth;
            
            if ~isempty(obj.EditBox)
                obj.EditBox.SetText(num2str(value, '%.6g'));
            end
            
            obj.AddPostSetListener(value_instance_handle, value_property_name, @obj.PropertyChangedCallback);
            
            if ~isempty(limits_property_name)
                obj.AddPostSetListener(limits_instance_handle, limits_property_name, @obj.PropertyLimitsChangedCallback);
            end
        end

        function enabled = UpdateToolEnabled(obj, gui_app)
            enabled = obj.Tool.IsEnabled(gui_app);
        end
    end
    
    methods (Access = protected)
        function SliderCallback(obj, hObject, arg2)
            SliderCallback@GemLabelSlider(obj, hObject, arg2);
            
            [instance_handle, value_property_name, ~, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            
            value = obj.Slider.SliderValue;
            if obj.FixToInteger
                value = round(value);
            end
            instance_handle.(value_property_name) = value;
            obj.EditBox.SetText(num2str(value, '%.6g'));
        end
        
        function EditBoxCallback(obj, hObject, arg2)
            EditBoxCallback@GemLabelSlider(obj, hObject, arg2);
            
            [instance_handle, value_property_name, ~, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            
            value = round(str2double(obj.EditBox.Text));
            instance_handle.(value_property_name) = value;
            obj.Slider.SetSliderValue(value);
        end
        
        function PropertyChangedCallback(obj, ~, ~, ~)
            [instance_handle, value_property_name, ~, ~] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            value = instance_handle.(value_property_name);            
            obj.Slider.SetSliderValue(value);
            obj.EditBox.SetText(num2str(value, '%.6g'));
        end
        
        function PropertyLimitsChangedCallback(obj, ~, ~, ~)
            [~, ~, limits_instance_handle, limits_property_name] = obj.Tool.GetHandleAndProperty(obj.GuiApp);
            limits = limits_instance_handle.(limits_property_name);            
            obj.Slider.SetSliderLimits(limits(1), limits(2));
            range = limits(2) - limits(1);
            if abs(range) >= 100
                obj.FixToInteger = true;
            else
                obj.FixToInteger = false;
            end
        end
        
    end    
end