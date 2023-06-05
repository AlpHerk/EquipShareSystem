<script setup lang="ts"> 

</script>
<template>
	<div class="notice_view">
		<el-carousel height="180px">
			<el-carousel-item class="el-carousel-item" key="1">
				<img class="bannerimg" src="@/assets/banner/banner1.jpg" alt="">
			</el-carousel-item>
			<el-carousel-item class="el-carousel-item" key="2">
				<img class="bannerimg" src="@/assets/banner/banner2.jpg" alt="">
			</el-carousel-item>
		</el-carousel>

		<div class="custom_block">
			<el-row>
				<el-col :span="11">
					<div class="block_header">
						<div class="header_title"><strong>通知公告</strong></div>
						<a class="header_more" href="http://dxyq.njtech.edu.cn/genee/category/notice">更多&gt;</a>
					</div>

					<div class="block_body">
						<el-row align="middle">
							<el-col :span="4">
								<div class="calendar_box">
									<div class="year">2023</div>
									<div class="data">5.19</div>
								</div>
							</el-col>
							<el-col :span="20">
								<div class="message"><a class="title"
										href="http://dxyq.njtech.edu.cn/genee/post/26">实验室建设与管理处召开专题调研座谈会</a>
									<div class="info">
										5月18日下午，实验室建设与管理处召开校级分析测试中心建设和大型仪器设备管理专业技术队伍建设专题调研座谈会。部分学院实验教学中心负责人、实验室安全员、大型仪器设备管理员参加座谈会，陈晓猛处长主持座谈会。
									</div>
								</div>
							</el-col>
						</el-row>
					</div>

					<div class="block_body">
						<el-row align="middle">
							<el-col :span="4">
								<div class="calendar_box">
									<div class="year">2023</div>
									<div class="data">5.19</div>
								</div>
							</el-col>
							<el-col :span="20">
								<div class="message"><a class="title"
										href="http://dxyq.njtech.edu.cn/genee/post/25">省科技厅、省科技资服务中心赴我校开展专题调研</a>
									<div class="info">
										5月15日下午，省科技厅、省科技资源统筹服务中心有关领导专家赴我校专题调研基础支撑类平台建设情况。省科技厅机关党委三级调研员马石山、省科技资源统筹服务中心副主任孙兴莲、中国药科大学实验室与设备管理处副处长刘剑锋、南京信息工程大学管理工程学院副院长曹玲出席调研座谈会。实验室建设与管理处处长陈晓猛主持调研座谈会。
									</div>
								</div>
							</el-col>
						</el-row>
					</div>

					<div class="block_body">
						<el-row align="middle">
							<el-col :span="4">
								<div class="calendar_box">
									<div class="year">2023</div>
									<div class="data">04.07</div>
								</div>
							</el-col>
							<el-col :span="20">
								<div class="message"><a class="title"
										href="http://dxyq.njtech.edu.cn/genee/post/24">关于大型仪器设备共享平台(二期)上线运行的通知</a>
									<div class="info">
										学校大型仪器设备开放共享平台（二期）建设现已完成，目前实现了校大型仪器设备信息共享和网上开放预约申请等功能。为了让广大师生及时了解大型仪器共享平台的使用方法，提高大型仪器使用效率，现将平台上线运行有关事项通知如下：
									</div>
								</div>
							</el-col>
						</el-row>
					</div>
				</el-col>


				<el-col :span="2" />


				<el-col :span="11">
					<div class="block_header">
						<div class="header_title"><strong>快速链接</strong></div>
					</div>

					<el-row justify="space-between">
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								通用设备竞价平台
							</a>
						</el-col >
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								实验材料采购平台
							</a>
						</el-col>
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								国有资产管理平台
							</a>
						</el-col>
					</el-row>

					<el-row justify="space-between">
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								实验安全管理平台
							</a>
						</el-col >
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								安全环保交易平台
							</a>
						</el-col>
						<el-col :span="6">
							<a class="link_block" href="http://jjxt.njtech.edu.cn">
								江苏省政府采购网
							</a>
						</el-col>
					</el-row>

				</el-col>

			</el-row>
		</div>
	</div>
</template>
  
<style scoped lang="scss">
.link_block {
	margin-top: 20px;
	padding: 0 10px;
	height: 40px; 
	font-size: 12px;
	float: left;
	display: flex;
	align-items: center;
	color: $color_primary;
	border: 1px solid $color_primary;
	text-decoration: none;
}

.link_block:hover {
	font-weight: bold;
}

.el-carousel {
	.el-carousel-item {
		color: #475669;
		opacity: 0.75;
		line-height: 150px;
		margin: 0;
		text-align: center;

		.bannerimg {
			width: 100%;
			height: auto;
		}
	}

	.el-carousel-item:nth-child(2n) {
		background-color: #99a9bf;
	}

	.el-carousel-item:nth-child(2n + 1) {
		background-color: #d3dce6;
	}


}

.custom_block {
	margin: 10px 40px;

	.block_header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		border-bottom: 2px solid $color_primary;
		display: flex;
		height: 50px;

		.header_title {
			font-size: 16px;
		}

		.header_more {
			color: #999;
			font-weight: 500;
			text-decoration: none;
			bottom: 10px;
			font-size: 14px;
			position: relative;
			top: 0;
			right: 0;
		}
	}

	.block_body {
		margin: 20px 0;

		.message {
			.title {
				color: #333;
				font-size: 16px;
				text-decoration: none;
			}

			.title:hover {
				color: #0056b3;
			}

			.info {
				padding-top: 8px;
				width: 100%;
				color: #999;
				font-size: 14px;
				margin-bottom: 0;
				text-overflow: ellipsis;
				display: -webkit-box;
				overflow: hidden;
				-webkit-line-clamp: 1;
				-webkit-box-orient: vertical;
				text-align: justify;
			}
		}
	}
}




.calendar_box {
	border: 1px solid $color_primary;
	width: 50px;

	.year {
		background: $color_primary;
		height: 20px;
		font-size: 12px;
		line-height: 20px;
		color: #fff;
		text-align: center;
		font-weight: 400;
	}

	.data {
		text-align: center;
		line-height: 30px;
		font-weight: 500;
		font-size: 14px;
	}
}
</style>
  