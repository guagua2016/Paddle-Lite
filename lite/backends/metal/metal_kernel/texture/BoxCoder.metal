/* Copyright (c) 2021 PaddlePaddle Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. */

#include <metal_stdlib>
#include "Common.metal"
using namespace metal;

kernel void box_coder(texture2d_array<ftype, access::read> priorBox[[texture(0)]],
    texture2d_array<ftype, access::read> priorBoxVar[[texture(1)]],
    texture2d_array<ftype, access::read> targetBox[[texture(2)]],
    texture2d_array<ftype, access::write> output[[texture(3)]],
    uint3 gid[[thread_position_in_grid]]) {
    ftype4 p = priorBox.read(uint2(0, gid.x), gid.z);
    ftype4 pv = priorBoxVar.read(uint2(0, gid.x), gid.z);
    ftype4 t;
    t[0] = targetBox.read(uint2(0, gid.x), gid.z)[0];
    t[1] = targetBox.read(uint2(1, gid.x), gid.z)[0];
    t[2] = targetBox.read(uint2(2, gid.x), gid.z)[0];
    t[3] = targetBox.read(uint2(3, gid.x), gid.z)[0];

    ftype px = (p.x + p.z) / 2;
    ftype py = (p.y + p.w) / 2;
    ftype pw = p.z - p.x;
    ftype ph = p.w - p.y;

    ftype tx = pv.x * t.x * pw + px;
    ftype ty = pv.y * t.y * ph + py;
    ftype tw = exp(pv.z * t.z) * pw;
    ftype th = exp(pv.w * t.w) * ph;

    ftype4 r;
    r.x = tx - tw / 2;
    r.y = ty - th / 2;
    r.z = tx + tw / 2;
    r.w = ty + th / 2;

    output.write(r, gid.xy, gid.z);
}
