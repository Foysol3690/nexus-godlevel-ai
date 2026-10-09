#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Uniform order must match OrbEnergyField._bindShader.
uniform vec2 uCenter;
uniform float uRadius;
uniform float uTime;
uniform float uEnergy;
uniform float uBass;
uniform float uTreble;
uniform float uCool;

out vec4 fragColor;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = p * 2.03 + vec2(1.7, 9.2);
    a *= 0.5;
  }
  return v;
}

vec3 spectrum(float t) {
  vec3 cyan = vec3(0.25, 0.9, 1.0);
  vec3 blue = vec3(0.24, 0.48, 1.0);
  vec3 violet = vec3(0.54, 0.36, 1.0);
  vec3 magenta = vec3(0.89, 0.3, 0.88);
  vec3 orange = vec3(1.0, 0.6, 0.24);
  t = clamp(t, 0.0, 1.0);
  if (t < 0.25) return mix(cyan, blue, t / 0.25);
  if (t < 0.5) return mix(blue, violet, (t - 0.25) / 0.25);
  if (t < 0.75) return mix(violet, magenta, (t - 0.5) / 0.25);
  return mix(magenta, orange, (t - 0.75) / 0.25);
}

float coolHue(float t) {
  return mix(t, 0.12 + t * 0.36, uCool);
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 p = (frag - uCenter) / uRadius;
  float d = length(p);

  vec3 col = vec3(0.0);
  float alpha = 0.0;

  if (d < 1.0) {
    float z = sqrt(1.0 - d * d);
    vec3 n = vec3(p, z);

    // Spherical distortion so the plasma wraps around the glass shell.
    vec2 q = p * 1.5 / (0.55 + z * 0.45);
    float ang = uTime * 0.22 + uBass * 0.7;
    float ca = cos(ang);
    float sa = sin(ang);
    q = vec2(q.x * ca - q.y * sa, q.x * sa + q.y * ca);

    float f = fbm(q * 1.35 + vec2(uTime * 0.16, -uTime * 0.11));
    float g = fbm(q * 2.5 - vec2(f * 1.6 + uTime * 0.21, f * 0.8));
    float lines = 1.0 - abs(sin((g * 5.5 + f * 3.0 + uTime * 0.35) * 3.14159));
    float filaments = pow(lines, 7.0);

    float hueT = coolHue(clamp(0.5 + p.x * 0.45 + (g - 0.5) * 0.55, 0.0, 1.0));
    vec3 base = spectrum(hueT);

    float core = exp(-d * d * 3.2);
    vec3 inner = base * (0.22 + 0.6 * g);
    inner += vec3(0.82, 0.92, 1.0) * core * (0.3 + 0.55 * uEnergy);
    inner += base * filaments * (0.35 + 0.9 * uTreble + 0.35 * uEnergy);

    float fresnel = pow(1.0 - z, 2.4);
    vec3 rim = spectrum(coolHue(clamp(0.55 + p.x * 0.5 - p.y * 0.15, 0.0, 1.0))) * fresnel * 1.25;

    vec3 light = normalize(vec3(-0.45, -0.55, 0.7));
    float spec = pow(max(dot(n, light), 0.0), 30.0);
    float spec2 = pow(max(dot(n, normalize(vec3(0.5, 0.6, 0.6))), 0.0), 60.0);

    float edge = smoothstep(1.0, 0.965, d);
    col = (inner * (0.55 + 0.45 * z) + rim + vec3(1.0) * spec * 0.85 +
           spectrum(coolHue(0.9)) * spec2 * 0.5) * edge;
    alpha = edge * 0.6;
  }

  float outside = max(d - 1.0, 0.0);
  float halo = exp(-outside * 3.0) * step(1.0, d);
  vec3 haloCol = spectrum(coolHue(clamp(0.5 + p.x * 0.4, 0.0, 1.0)));
  float haloStrength = halo * (0.22 + 0.6 * uEnergy);
  col += haloCol * haloStrength;
  alpha = max(alpha, haloStrength * 0.5);

  // Premultiplied, emissive output.
  fragColor = vec4(col, alpha);
}
