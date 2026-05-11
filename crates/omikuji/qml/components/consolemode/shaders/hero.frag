#version 440

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
} ubuf;

layout(binding = 1) uniform sampler2D src;

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

void main() {
    vec2 uv = qt_TexCoord0;
    vec4 color = texture(src, uv);

    float bottomMask = smoothstep(0.35, 1.0, uv.y);

    float fromCenter = abs(uv.x - 0.5) * 2.0;
    float sideMask = smoothstep(0.55, 1.0, fromCenter);
    sideMask *= smoothstep(0.0, 0.8, uv.y);

    float darken = max(bottomMask, sideMask);
    darken = pow(darken, 1.2);

    color.rgb = mix(color.rgb, vec3(0.0), darken * 0.92);

    fragColor = color * ubuf.qt_Opacity;
}
