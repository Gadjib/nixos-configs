{ ... }:

{
  home.file.".local/share/Steam/steamapps/common/Half-Life 2/hl2_complete/cfg/autoexec.cfg" = {
    force = true;
    text = ''
      // Stability profile for the native Linux Source engine.
      mat_queue_mode "0"
      r_threaded_renderables "0"
      r_threaded_particles "0"
      r_threaded_client_shadow_manager "0"
      cl_threaded_bone_setup "0"
      cl_threaded_client_leaf_system "0"

      // Avoid the crashing OpenGL centroid/MSAA shader path.
      mat_antialias "0"
      mat_aaquality "0"

      mat_vsync "1"
      fps_max "60"
    '';
  };

  home.file.".local/share/Steam/steamapps/common/Half-Life 2/hl2/videoconfig_linux.cfg" = {
    force = true;
    text = ''
      "videoconfig"
      {
        "AutoConfigVersion" "1"
        "ScreenDisplayIndex" "0"
        "ScreenWidth" "1920"
        "ScreenHeight" "1200"
        "ScreenWindowed" "0"
        "ScreenNoBorder" "0"
        "ScreenMSAA" "0"
        "ScreenMSAAQuality" "0"
        "MotionBlur" "0"
        "ShadowDepthTexture" "0"
        "VRModeAdapter" "-1"
        "ScreenMonitorGamma" "2.200000"
        "mat_forceaniso" "16"
        "mat_picmip" "-1"
        "mat_trilinear" "0"
        "mat_vsync" "1"
        "mat_forcehardwaresync" "1"
        "mat_parallaxmap" "0"
        "mat_reducefillrate" "0"
        "r_lightmap_bicubic" "0"
        "r_shadowrendertotexture" "1"
        "r_rootlod" "0"
        "r_waterforceexpensive" "1"
        "r_waterforcereflectentities" "0"
        "mat_antialias" "0"
        "mat_aaquality" "0"
        "mat_specular" "1"
        "mat_bumpmap" "1"
        "mat_hdr_level" "0"
        "mat_colorcorrection" "1"
        "VendorID" "1"
        "DeviceID" "2"
        "DXLevel_V1" "90"
      }
    '';
  };
}
