Shader "Custom/VertexColorUnlit" {
 Properties {
    _Color ("Main Color", Color) = (1,1,1,1)
    _SpecColor ("Spec Color", Color) = (1,1,1,1)
    _Emission ("Emmisive Color", Color) = (0,0,0,0)
    _Shininess ("Shininess", Range (0.01, 1)) = 0.7
    _MainTex ("Base (RGB)", 2D) = "white" {}
}

SubShader {
    Pass {
        Material {
            Shininess [_Shininess]
            Specular [_SpecColor]
            Emission [_Emission]    
        }
        ColorMaterial AmbientAndDiffuse
        Lighting On
        SeparateSpecular On
        SetTexture [_MainTex] {
            Combine texture * primary, texture * primary
        }
        SetTexture [_MainTex] {
            constantColor [_Color]
            Combine previous * constant DOUBLE, previous * constant
        } 
    }
}

Fallback " VertexLit", 1
}
//     Category {
//         BindChannels { 
//             Bind "Color", color 
//             Bind "Vertex", vertex
//         }
//         SubShader { Pass {
//  			SetTexture [_MainTex] {
//  				combine texture * primary
//  			}
//  }
//     }
// }
// }

// Properties {
// 	_Color ("Color", Color) = (1,1,1,1)
// 	_MainTex ("Texture", 2D) = "white" {}
// }

// Category {
// 	Tags { "Queue"="Geometry" }
// 	Lighting Off
// 	BindChannels {
// 		Bind "Color", color
// 		Bind "Vertex", vertex
// 		Bind "TexCoord", texcoord
// 	}
	
// 	// ---- Dual texture cards
// 	SubShader {
// 		Pass {
// 			SetTexture [_MainTex] {
// 				combine texture * primary
// 			}
// 			SetTexture [_MainTex] {
// 				constantColor [_Color]
// 				combine previous lerp (previous) constant DOUBLE
// 			}
// 		}
// 	}
	
// 	// ---- Single texture cards (does not do vertex colors)
// 	SubShader {
// 		Pass {
// 			SetTexture [_MainTex] {
// 				constantColor [_Color]
// 				combine texture lerp(texture) constant DOUBLE
// 			}
// 		}
// 	}
// }
// }