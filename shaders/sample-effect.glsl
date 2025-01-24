
@header package main
@header import sg "../../libs/sokol-odin/sokol/gfx"
@header import sgp "../../libs/sokol-odin/sokol/gp"

@ctype vec2 sgp.Vec2
@ctype float f32

@vs vs
layout(location=0) in vec4 coord;
layout(location=1) in vec4 color;
layout(location=0) out vec2 texUV;
layout(location=1) out vec4 iColor;
void main() {
    gl_Position = vec4(coord.xy, 0.0, 1.0);
    texUV = coord.zw;
    iColor = color;
}
@end

@fs fs
layout(binding=0) uniform texture2D iTexChannel0;
layout(binding=1) uniform texture2D iTexChannel1;
layout(binding=0) uniform sampler iSmpChannel0;
layout(binding=1) uniform sampler iSmpChannel1;
layout(binding=1) uniform fs_uniforms {
    vec2 iVelocity;
    float iPressure;
    float iTime;
    float iWarpiness;
    float iRatio;
    float iZoom;
    float iLevel;
};
layout(location=0) in vec2 texUV;
layout(location=1) in vec4 iColor;
layout(location=0) out vec4 fragColor;
float noise(vec2 p) {
    return texture(sampler2D(iTexChannel1, iSmpChannel1), p).r;
}
void main() {
    vec3 tex_col = texture(sampler2D(iTexChannel0, iSmpChannel0), texUV).rgb;
    vec2 fog_uv = (texUV * vec2(iRatio, 1.0)) * iZoom;
    float f = noise(fog_uv - iVelocity*iTime);
    f = noise(fog_uv + f*iWarpiness);
    vec3 col = mix(tex_col, vec3(f) * iColor.rgb, iPressure);
    fragColor = vec4(col, 1.0);
}
@end

@program sample_effect vs fs
